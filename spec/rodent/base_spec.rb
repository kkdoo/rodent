require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../', 'examples/customers')

describe Rodent::Base do
  include EventedSpec::AMQPSpec
  include EventedSpec::SpecHelper

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }

  default_options({host: 'localhost', port: 5672})
  default_timeout(10)

  amqp_before do
    @channel = AMQP::Channel.new
    @channel.should be_open

    @message_id = BSON::ObjectId.new.to_s

    @replies_queue = @channel.queue(@message_id, exclusive: true, auto_delete: true)

    @consumer = AMQP::Consumer.new(@channel, @replies_queue)

    @consumer.consume do
      @consumer.on_delivery do |metadata, payload|
        @response = MultiJson.load(payload)
        metadata.ack
        @consumer.cancel
      end
    end

    CustomersAPI.bind
  end

  after(:all) do
    AMQP.cleanup_state
    done
  end

  it 'should return right response' do
    params = {name: 'Bob Marley', email: 'bob@example.com'}

    @channel.direct('rodent.requests').publish MultiJson.dump(params), routing_key: 'customers.create',
      message_id: @message_id, reply_to: @replies_queue.name

    done(2.0) do
      @response.should_not be_nil
      @response['status'].should == 201
      @response['headers'].should == {'API-Version' => 'v1'}
      @response['body'].should_not be_nil
      MultiJson.load(@response['body']).should == {'name' => 'Bob Marley', 'email' => 'bob@example.com'}
    end
  end
end
