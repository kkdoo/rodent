require 'json'
require 'multi_json'
require 'amqp'

module Rodent
  class Listener
    attr_reader :type
    attr_accessor :params, :status, :headers, :body

    def initialize(type, &block)
      @type = type
      @source = block
    end

    def bind
      AMQP::Channel.new do |channel|
        channel.prefetch(100)
        queue = channel.queue(@type, exclusive: true, auto_delete: true)
        queue.bind(channel.direct('rodent.requests'), routing_key: @type)
        queue.subscribe(ack: true) do |metadata, payload|
          self.body = call(MultiJson.load(payload))
          channel.default_exchange.publish(MultiJson.dump(response), routing_key: metadata.reply_to, correlation_id: metadata.message_id)
          metadata.ack
        end
      end
    end

    def call(params = {})
      self.params = params
      self.status = 200
      self.headers = {}
      unless respond_to?(method_name)
        define_singleton_method(method_name, @source)
      end
      MultiJson.dump(self.send(method_name))
    end

    def method_name
      ('rodent_' + @type).gsub('.', '_').to_sym
    end

    def response
      {status: status, headers: headers, body: body}
    end
  end
end
