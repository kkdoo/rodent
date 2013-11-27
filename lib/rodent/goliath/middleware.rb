require 'bson'
require 'json'
require 'multi_json'
require 'amqp'
require 'goliath'

module Rodent
  module Goliath
    class Middleware
      include ::Goliath::Rack::AsyncMiddleware

      def initialize(app, header_proxy_name = 'Rodent-Proxy')
        @header_proxy_name = header_proxy_name
        super(app)
      end

      def hook_into_callback_chain(env, *args)
        async_callback = env['async.callback']

        downstream_callback = proc do |status, headers, response|
          result_response = [status, headers, response]
          if proxy_type = headers.delete(@header_proxy_name)
            body = response.respond_to?(:body) ? response.body.join : response
            result_response = safely(env) { proxy_request(env, proxy_type, body, headers) }
          end
          async_callback.call(result_response) unless result_response == ::Goliath::Connection::AsyncResponse
        end

        env['async.callback'] = downstream_callback
      end

      protected
      def proxy_request(env, type, body, headers = {})
        async_callback = env['async.callback']

        message_id = BSON::ObjectId.new.to_s

        env.channels.execute(false) do |channel|
          replies_queue = channel.queue(message_id, exclusive: true, auto_delete: true)

          consumer = AMQP::Consumer.new(channel, replies_queue)
          bind_consumer(consumer, async_callback, headers)

          channel.direct('rodent.requests').publish(body, routing_key: type, message_id: message_id, reply_to: replies_queue.name)
        end

        ::Goliath::Connection::AsyncResponse
      end

      def bind_consumer(consumer, async_callback, headers)
        consumer.consume do
          consumer.on_delivery do |metadata, payload|
            response = MultiJson.load(payload)
            response['headers']['Content-Length'] = response['body'].to_s.bytes.count.to_s
            response['headers']['Content-Type'] = 'application/json'
            async_callback.call([response['status'], headers.merge(response['headers']), response['body']])
            metadata.ack
            consumer.cancel
          end
        end
      end
    end
  end
end
