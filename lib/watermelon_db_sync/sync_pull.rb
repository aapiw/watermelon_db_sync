module WatermelonDbSync
  class SyncPull < Sync
    attr_accessor :last_pulled_version, :models, :data

    def initialize(params)
      @last_pulled_version = params[:last_pulled_version].to_i || 0
      @push_id = params[:push_id]
      @models = WatermelonDbSync.configuration.sync_models
      @data = { last_global_seqs: 0, response: build_default_response }
    end

    def pull
      get_from_all
    end

    def get_from_all
      max_versions = @models.map do |model_name|
        model = model_name.constantize
        query(model)
      end

      @data[:last_global_seqs] =
        max_versions.flatten.compact.max || @last_pulled_version

      true
    rescue => e
      e.message
    end

    private

    def base_scope(model)
      model.respond_to?(:with_deleted) ? model.with_deleted : model.all
    end

    def deleted_scope(model)
      if model.respond_to?(:only_deleted)
        model.only_deleted
      else
        model.where.not(deleted_at_server: nil)
      end
    end

    def query(model)
      scope = base_scope(model)
        .where("version_created > ? OR version > ?", 
               @last_pulled_version, @last_pulled_version)

      scope = scope.where("push_id != ? OR push_id IS NULL", @push_id) if @push_id.present?

      created = scope
        .where(deleted_at_server: nil)
        .where("version_created > ?", @last_pulled_version)

      updated = scope
        .where(deleted_at_server: nil)
        .where("version > ? AND version_created <= ?", 
               @last_pulled_version, @last_pulled_version)

      deleted = deleted_scope(model)
        .where("version > ?", @last_pulled_version)
        .pluck(:id)

      table = model.table_name.to_sym

      @data[:response][table][:created] = created.as_json
      @data[:response][table][:updated] = updated.as_json
      @data[:response][table][:deleted] = deleted

      scope.pluck(:version, :version_created)
    end

    def build_default_response
      default = {}

      @models.each do |model_name|
        table = model_name.constantize.table_name.to_sym
        default[table] = {
          created: [],
          updated: [],
          deleted: []
        }
      end

      default
    end
  end
end