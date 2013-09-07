module Rodent
  class Base
    class << self
      attr_reader :listeners, :instance

      def listeners
        @listeners ||= []
      end

      def route(type)
        @listeners.each do |listener|
          return listener if type == listener.type
        end
        nil
      end

      def listen(type, &block)
        listeners << Rodent::Listener.new(type, &block)
      end

      def bind
        listeners.each(&:bind)
      end
    end
  end
end
