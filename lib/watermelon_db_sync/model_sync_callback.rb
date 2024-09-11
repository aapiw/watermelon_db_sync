# lib/watermelon_db_sync/model_sync.rb
module WatermelonDbSync
  module ModelSyncCallback
    extend ActiveSupport::Concern

    included do
      # Code to run when the module is included in a model
      acts_as_paranoid column: 'deleted_at_server'
      
      before_update :update_version_and_updated_at_server
      before_destroy :update_version
    end

    # handle updating version when record is updated
    def update_version_and_updated_at_server
      return unless WatermelonDbSync.configuration.sync_models.include? self.class.name
      self.version = Sync.next_global_seqs
      self.updated_at_server = Time.zone.now
    end

    # handle updating version when record is deleted
    def update_version
      return unless WatermelonDbSync.configuration.sync_models.include? self.class.name
      update_column(:version, Sync.next_global_seqs) #skip callback
    end

    class_methods do
    end
  end
end
