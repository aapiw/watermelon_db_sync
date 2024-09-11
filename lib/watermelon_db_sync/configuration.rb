module WatermelonDbSync
  class Configuration
    attr_accessor :sync_models

    def initialize
      @sync_models = []
    end
  end
end
