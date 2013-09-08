require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'examples/proxy')

describe Rodent::Goliath::Middleware do
  include EventedSpec::AMQPSpec
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }

  default_options({host: 'localhost', port: 5672})
  default_timeout(10)

  amqp_before do
    @channel = AMQP::Channel.new
    @channel.should be_open

    @queue = @channel.queue('customers.create', exclusive: true, auto_delete: true)
    @queue.bind(@channel.direct('rodent.requests'), routing_key: 'customers.create')
    @queue.subscribe(ack: true) do |metadata, payload|
      json = {status: 201, headers: {}, body: payload}
      @channel.default_exchange.publish(MultiJson.dump(json), routing_key: metadata.reply_to, correlation_id: metadata.message_id)
      metadata.ack
    end
  end

  after(:all) do
    AMQP.cleanup_state
    done
  end

  it 'should return right response' do
    with_api(ProxyApp) do
      params = {name: 'John Snow', email: 'john@example.com'}
      post_request({path: '/customers', body: params}) do |req|
        done do
          req.response_header.status.should == 201
          req.response_header['CONTENT_LENGTH'].should == MultiJson.dump(params).length.to_s
          req.response_header['CONTENT_TYPE'].should == 'application/json'
          body = JSON.parse(req.response)
          body.should == {'name' => 'John Snow', 'email' => 'john@example.com'}
        end
      end
    end
  end
end
