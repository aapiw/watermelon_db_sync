module WatermelonDbSync
  class SyncPush < Sync

    attr_accessor :models, :data, :params

    def initialize(params)
      @models = WatermelonDbSync.configuration.sync_models
      @params = params
      @data = {last_global_seqs:0}
      @push_id = rand(1..1_000_000_000)
    end

    def push
      begin
          if has_conflict_version?
            @data[:error_code] = "WDBS2"
            raise StandardError.new("the data has a conflict version, please pull first")
          else
            ActiveRecord::Base.transaction do
              @models.each do |model|
                self.submit_records!(model) if @params.keys.include? eval(model).table_name
              end
                @data[:success] = true
                sync_pull = SyncPull.new(last_pulled_version: @params["last_pulled_version"], push_id: @push_id)
                sync_pull.pull
                @data[:response] = sync_pull.data[:response]
                @data[:last_global_seqs] = sync_pull.data[:last_global_seqs]
            end
          end
      rescue StandardError => e
        @data[:success] = false
        @data[:message] = e.message
      end
    end


    def submit_records!(model)
      table = @params[model.tableize]
      table["created"]&.each do |data|
        data = except_data(data)
        data["push_id"] = @push_id

        find_or_new = eval(model).find(data["id"]) rescue nil
        if find_or_new.blank?
          find_or_new = eval(model).new(data)
          find_or_new.id = data["id"]
          find_or_new.created_at = data["created_at"]
          find_or_new.updated_at = data["updated_at"]
          find_or_new.save!
        else
          find_or_new.update!(data)
        end
      end

      table["updated"]&.each do |data|
        data = except_data(data)
        data["push_id"] = @push_id

        find_record = eval(model).find(data["id"]) rescue nil

        if find_record.nil? && eval(model).only_deleted.find(data["id"])
          @data[:error_code] = "WDBS1"
          raise StandardError.new("id=#{data["id"]} of the #{model} was deleted, please pull first")
        end
        find_record.update!(data.except("id"))
      end

      table["deleted"]&.each do |data|
        find_record = eval(model).find(data) rescue nil

        if find_record.present?
          find_record.update_column(:push_id, @push_id)
          find_record.destroy
        end
      end
      
    end

    def except_data(data)
      data.except("version", "version_created", "created_at_server", "updated_at_server", "deleted_at_server", "push_id", "_status", "_changed")
    end

    def has_conflict_version?
        conflict = false
        @models.each do |model|
        
        #keep original object @params
        params = Marshal.load(Marshal.dump(@params))
        table = params[model.tableize]
        if (params.keys.include? eval(model).table_name)
          collect_ids = table["created"]

          if table["updated"].present?
            updated = table["updated"]
            collect_ids.concat(updated)
          end

          collect_ids = collect_ids&.map{|d|d["id"]}
          collect_ids.concat(table["deleted"]) if table["deleted"].present? 
          conflict = eval(model).with_deleted
                              .where(id: collect_ids)
                              .where("version_created > #{@params["last_pulled_version"]} OR version > #{@params["last_pulled_version"]}").exists?
        end
          break if conflict
        end
        return conflict
    end

  end
end