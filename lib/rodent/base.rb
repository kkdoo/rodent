module Rodent
  class Base
    class << self
      attr_reader :listeners, :instance
      attr_accessor :error_handler

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
        listeners.each do |listener|
          listener.bind(error_handler)
        end
      end
    end
  end
end
