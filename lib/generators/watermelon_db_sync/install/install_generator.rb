module WatermelonDbSync::Generators
  class InstallGenerator < Rails::Generators::Base

    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __dir__)

    def copy_initializer
      template "initializer.rb", "config/initializers/watermelon_db_sync.rb"
    end

      def copy_migrations
        migration_template "create_sequence.rb", "db/migrate/create_global_seqs.rb"
      end

      def self.next_migration_number(dirname)
        InstallGenerator.timestamp
      end

      def self.timestamp
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
    
  end
end
2