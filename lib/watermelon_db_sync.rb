# frozen_string_literal: true
require 'acts_as_paranoid'

require_relative "watermelon_db_sync/version"
require_relative "watermelon_db_sync/configuration"
require_relative "watermelon_db_sync/model_sync_callback"
require_relative "watermelon_db_sync/sync"
require_relative "watermelon_db_sync/sync_pull"
require_relative "watermelon_db_sync/sync_push"

module WatermelonDbSync
  class Error < StandardError; end

  # @configuration = Configuration.new

  class << self
    attr_accessor :configuration
    
    # Lazily initialize the configuration object
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
