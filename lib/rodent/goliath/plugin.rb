require 'em-synchrony'
require 'amqp'
require 'goliath'

module Rodent
  module Goliath
    class Plugin
      def initialize(address, port, config, status, logger)
        @port = port
        @status = status
        @config = config
        @logger = logger
      end

      def run(connection_string = 'amqp://guest:guest@localhost', pool_size = 50)
        @config['amqp'] = AMQP.connect(connection_string)
        @config['channels'] = EM::Synchrony::ConnectionPool.new(size: pool_size) do
          AMQP::Channel.new(@config['amqp'])
        end
      end
    end
  end
end
