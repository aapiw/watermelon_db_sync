module WatermelonDbSync
  class SyncPull < Sync
    
    attr_accessor :last_pulled_version, :models, :data

    def initialize(params)
      @last_pulled_version = params[:last_pulled_version] || 0
      @push_id = params[:push_id]
      @format_response = {created: [], updated: [], deleted: [] }
      @models = WatermelonDbSync.configuration.sync_models
      @data = {last_global_seqs: 0, response: build_default_response}
    end

    def pull
      self.get_from_all
    end

    def get_from_all
      begin
        max_list = []
        @models.each do |model|
          max_list << self.query(eval(model))
        end

        @data[:last_global_seqs] = max_list.flatten.max || @last_pulled_version.to_i #Sync.last_global_seqs
        return true
      rescue => e
        e.message
      end
    end

    # Filtered by push_id, for differentiate record just pushed
    def query(model=nil)

      all_with_deleted = model.with_deleted.where("version_created > #{@last_pulled_version} OR version > #{@last_pulled_version}")
      max_list = all_with_deleted.pluck(:version, :version_created)

      all_with_deleted = all_with_deleted.where("push_id != ? or push_id is ?", @push_id, nil) if @push_id.present?

      created = all_with_deleted.where(deleted_at_server: nil).where("version_created > #{@last_pulled_version}")

      updated = all_with_deleted.where(deleted_at_server: nil).where("created_at_server != updated_at_server")
      new_updated = []
      updated.each do |obj_updated|
        new_updated << obj_updated unless created.map{|d|d.as_json}.include?(obj_updated.as_json)
      end
      
      deleted = all_with_deleted.only_deleted
      deleted = deleted.pluck(:id)
      
      @data[:response][model.table_name.to_sym][:created] = created&.as_json
      @data[:response][model.table_name.to_sym][:updated] = new_updated&.as_json
      @data[:response][model.table_name.to_sym][:deleted] = deleted&.as_json
      
      max_list
    end

    def build_default_response
      default = Hash.new { |hash, key| hash[key] = {} }
      @models.each do |model|
        default[eval(model).table_name.to_sym][:created] = {}
        default[eval(model).table_name.to_sym][:deleted] = {}
        default[eval(model).table_name.to_sym][:updated] = {}
      end
      default
    end

  end
end