require 'rodent'

class ProxyApp < Goliath::API
  plugin Rodent::Goliath::Plugin
  use Rodent::Goliath::Middleware
  use Goliath::Rack::Params

  def response(env)
    [201, {'Rodent-Proxy' => 'customers.create'}, MultiJson.dump(params)]
  end
end
