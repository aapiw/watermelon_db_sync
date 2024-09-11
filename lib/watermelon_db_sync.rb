# frozen_string_literal: true

require_relative "watermelon_db_sync/version"
require_relative "watermelon_db_sync/configuration"

module WatermelonDbSync
  class Error < StandardError; end

  @configuration = Configuration.new

  class << self
    attr_accessor :configuration

    def configure
      yield(configuration)
    end
  end
end
