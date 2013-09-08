# Rodent

Rodent is an open source asynchronous framework for Micro Service Architecture (MSA). It is a lightweight and designed to easily develop APIs. Main goals is scaling, simplicity and perfomance.

The framework uses [Goliath](https://github.com/postrank-labs/goliath) as HTTP proxy and [AMQP](https://github.com/ruby-amqp/amqp) protocol to connect MSA for handling requests. Micro Services can be runned separately and multiple times for scaling, hot-reloading or language independence. All requests are load balanced with same MSA.

You can learn more about MSA in great [article](http://yobriefca.se/blog/2013/04/29/micro-service-architecture/) by James Hughes.

## Installation & Prerequisites

Rodent is available as a gem, to install it just install the gem

```bash
$> gem install rodent
```

If you're using Bundler, add the gem to Gemfile

```ruby
gem 'rodent'
```

## Getting Started: Hello World

Proxy server for sending HTTP requests into Micro Service (based on [Grape](https://github.com/intridea/grape))

```ruby
# proxy.rb

require 'rodent'
require 'grape'

class CustomersProxy < Grape::API
  version 'v1', using: :path
  format :json
  default_format :json

  resource :customers do
    params do
      requires :name, type: String
      requires :email, type: String
    end
    post '/' do
      header 'Rodent-Proxy', 'customers.create'

      {name: params[:name], email: params[:email]}
    end
  end
end

class ProxyApp < Goliath::API
  plugin Rodent::Goliath::Plugin
  use Rodent::Goliath::Middleware
  use Goliath::Rack::Params

  def response(env)
    CustomersProxy.call(env)
  end
end
```

Micro Service for handling requests

```ruby
# customers.rb

require 'rodent'

class Customer
  attr_accessor :name, :email

  def initialize(options)
    @name = options['name']
    @email = options['email']
  end

  def as_json
    {recipient: [name, ' <', email, '>'].join}
  end
end

class CustomersAPI < Rodent::Base
  listen 'customers.create' do
    self.status = 201

    @customer = Customer.new(params)
    @customer.as_json
  end
end

class CustomersServer < Rodent::Server
  configure do
    set :connection, 'amqp://guest:guest@localhost'
  end

  run do
    Signal.trap('INT') { Rodent::Server.stop }

    [CustomersAPI]
  end
end
```

Run proxy server

```bash
$> ruby proxy.rb -v -s -e development -p 3000
```

Run micro service

```bash
$> ruby customers.rb
```

Then you can test it
```bash
$> curl -X POST localhost:3000/v1/customers -d "name=Bob" -d "email=bob@example.com"
```

## Performance:

My results is below

```bash
Server Software:        Goliath
Server Hostname:        localhost
Server Port:            3000

Document Path:          /v1/customers
Document Length:        2 bytes

Concurrency Level:      50
Time taken for tests:   2.450 seconds
Complete requests:      1000
Failed requests:        0
Write errors:           0
Total transferred:      126000 bytes
HTML transferred:       2000 bytes
Requests per second:    408.18 [#/sec] (mean)
Time per request:       122.495 [ms] (mean)
Time per request:       2.450 [ms] (mean, across all concurrent requests)
Transfer rate:          50.23 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    2   1.0      2       5
Processing:    51  118  40.5    116     233
Waiting:       45  116  41.0    115     232
Total:         51  120  40.7    117     235
```

## License & Acknowledgments

Rodent is distributed under the MIT license, for full details please see the LICENSE file.
