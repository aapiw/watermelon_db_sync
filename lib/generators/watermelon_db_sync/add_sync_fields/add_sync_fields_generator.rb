module WatermelonDbSync::Generators
  class AddSyncFieldsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

      # Specify the source for the migration template
      source_root File.expand_path('../templates', __dir__)

      # Take the model name as an argument
      argument :model_name, type: :string

      def copy_migrations
        # Use the helper methods directly to set the migration file name and path
        migration_template "add_sync_fields_migration.rb.erb", "db/migrate/#{migration_file_name}.rb"
      end

      # Generates the next migration number with a timestamp
      def self.next_migration_number(dirname)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      # Generates the migration file name based on the model name
      def migration_file_name
        "add_sync_fields_to_#{model_name.tableize}"
      end

      # Generates the migration class name to use in the template
      def migration_class_name
        "AddSyncFieldsTo#{model_name.tableize.camelize}"
      end
    
  end
end