module WatermelonDbSync
  class SyncPush < Sync
    attr_accessor :models, :data, :params

    def initialize(params)
      @models = WatermelonDbSync.configuration.sync_models
      @params = params
      @data = { last_global_seqs: 0 }
      @push_id = rand(1..1_000_000_000)
    end

    def push
      if has_conflict_version?
        @data[:success] = false
        @data[:error_code] = "WDBS2"
        @data[:message] = "Conflict version detected. Please pull first."
        return
      end

      ActiveRecord::Base.transaction do
        @models.each do |model_name|
          model = model_name.constantize
          next unless @params.key?(model.table_name)

          submit_records!(model)
        end

        sync_pull = SyncPull.new(
          last_pulled_version: @params["last_pulled_version"],
          push_id: @push_id
        )

        sync_pull.pull

        @data[:success] = true
        @data[:response] = sync_pull.data[:response]
        @data[:last_global_seqs] = sync_pull.data[:last_global_seqs]
      end
    rescue => e
      @data[:success] = false
      @data[:message] = e.message
    end

    private

    def base_scope(model)
      model.respond_to?(:with_deleted) ? model.with_deleted : model.all
    end

    def submit_records!(model)
      table = @params[model.table_name]

      table["created"]&.each do |record|
        record = sanitize(record)
        record["push_id"] = @push_id

        obj = model.find_by(id: record["id"]) || model.new
        obj.assign_attributes(record)
        obj.save!
      end

      table["updated"]&.each do |record|
        record = sanitize(record)
        record["push_id"] = @push_id

        obj = model.find(record["id"])
        obj.update!(record.except("id"))
      end

      table["deleted"]&.each do |id|
        obj = model.find_by(id: id)
        next unless obj

        obj.update_column(:push_id, @push_id)
        obj.destroy
      end
    end

    def sanitize(data)
      data.except(
        "version",
        "version_created",
        "created_at_server",
        "updated_at_server",
        "deleted_at_server",
        "push_id",
        "_status",
        "_changed"
      )
    end

    def has_conflict_version?
      @models.any? do |model_name|
        model = model_name.constantize
        table = @params[model.table_name]
        next false unless table

        ids = []
        ids += table["created"]&.map { |d| d["id"] } || []
        ids += table["updated"]&.map { |d| d["id"] } || []
        ids += table["deleted"] || []

        base_scope(model)
          .where(id: ids)
          .where("version_created > ? OR version > ?", 
                 @params["last_pulled_version"].to_i,
                 @params["last_pulled_version"].to_i)
          .exists?
      end
    end
  end
end