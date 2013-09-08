require 'rodent'

class Customer
  attr_accessor :name, :email

  def initialize(options)
    @name = options['name']
    @email = options['email']
  end

  def as_json
    {name: name, email: email}
  end
end

class CustomersAPI < Rodent::Base
  listen 'customers.create' do
    self.status = 201
    self.headers['API-Version'] = 'v1'

    @customer = Customer.new(params)
    @customer.as_json
  end
end
