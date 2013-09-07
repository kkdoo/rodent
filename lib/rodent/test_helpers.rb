module Rodent
  module Test
    module Helpers
      def request(path, *args)
        @rodent_response = api.route(path).call(*args)
      end

      def response
        @rodent_response
      end
    end
  end
end
