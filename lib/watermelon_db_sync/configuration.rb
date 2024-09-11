module WatermelonDbSync
  class Configuration
    attr_accessor :sequence_name, :models

    def initialize
      @sequence_name = 'global_sequence'
      @models = ['']
    end
  end
end
