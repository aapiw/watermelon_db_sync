module WatermelonDbSync
  class Sync
    class << self
      def last_global_seqs
        ActiveRecord::Base.connection.execute("select last_value from global_seqs").first["last_value"]
      end
      
      def next_global_seqs
        ActiveRecord::Base.connection.select_value("SELECT nextval('global_seqs')")
      end
    end
  end
end