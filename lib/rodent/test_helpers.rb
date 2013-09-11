require 'multi_json'

module Rodent
  module Test
    module Helpers
      def request(path, *args)
        @rodent_response = MultiJson.load(api.route(path).call(*args))
      end

      def response
        @rodent_response
      end
    end
  end
end
