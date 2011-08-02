module Fog
  class Vcloud < Fog::Service
    module Generators

      def unauthenticated_basic_request(*args)
        self.class_eval <<-EOS, __FILE__,__LINE__
          def #{args[0]}(uri)
            unauthenticated_request({
              :expects => #{args[1] || 200},
              :method  => '#{args[2] || 'GET'}',
              :headers => #{args[3] ? args[3].inspect : '{}'},
              :parse => true,
              :uri     => uri })
          end
        EOS
      end

      def basic_request(*args)
        self.class_eval <<-EOS, __FILE__,__LINE__
          def #{args[0]}(uri)
            request({
              :expects => #{args[1] || 200},
              :method  => '#{args[2] || 'GET'}',
              :headers => #{args[3] ? args[3].inspect : '{}'},
              :body => '#{args[4] ? args[4] : ''}',
              :parse => true,
              :uri     => uri })
          end
        EOS
      end
    end
  end
end
