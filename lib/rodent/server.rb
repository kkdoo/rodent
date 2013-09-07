require 'amqp'

module Rodent
  class Server
    class << self
      attr_accessor :settings

      def configure(&block)
        @settings ||= {}
        yield
      end

      def set(attr, value)
        settings[attr] = value
      end

      def run(&block)
        EM.run do
          AMQP.connection ||= AMQP.connect(settings[:connection])

          block.call.each(&:bind)
        end
      end

      def stop
        AMQP.connection.close { EM.stop }
      end
    end
  end
end
