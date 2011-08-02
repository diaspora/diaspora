require 'rack/openid'
require 'omniauth/openid/gapps'
require 'omniauth/openid'

module OmniAuth
  module Strategies
    # OmniAuth strategy for connecting via OpenID. This allows for connection
    # to a wide variety of sites, some of which are listed [on the OpenID website](http://openid.net/get-an-openid/).
    class OpenID
      include OmniAuth::Strategy

      attr_accessor :options

      IDENTIFIER_URL_PARAMETER = 'openid_url'

      AX = {
        :email => 'http://axschema.org/contact/email',
        :name => 'http://axschema.org/namePerson',
        :nickname => 'http://axschema.org/namePerson/friendly',
        :first_name => 'http://axschema.org/namePerson/first',
        :last_name => 'http://axschema.org/namePerson/last',
        :city => 'http://axschema.org/contact/city/home',
        :state => 'http://axschema.org/contact/state/home',
        :website => 'http://axschema.org/contact/web/default',
        :image => 'http://axschema.org/media/image/aspect11'
      }

      # Initialize the strategy as a Rack Middleware.
      #
      # @param app [Rack Application] Standard Rack middleware application argument.
      # @param store [OpenID Store] The [OpenID Store](http://github.com/openid/ruby-openid/tree/master/lib/openid/store/)
      #   you wish to use. Defaults to OpenID::MemoryStore.
      # @option options [Array] :required The identity fields that are required for the OpenID
      #   request. May be an ActiveExchange schema URL or an sreg identifier.
      # @option options [Array] :optional The optional attributes for the OpenID request. May
      #   be ActiveExchange or sreg.
      # @option options [Symbol, :open_id] :name The URL segment name for this provider.
      def initialize(app, store = nil, options = {}, &block)
        super(app, (options[:name] || :open_id), &block)
        @options = options
        @options[:required] ||= [AX[:email], AX[:name], AX[:first_name], AX[:last_name], 'email', 'fullname']
        @options[:optional] ||= [AX[:nickname], AX[:city], AX[:state], AX[:website], AX[:image], 'postcode', 'nickname']
        @store = store
      end

      protected

      def dummy_app
        lambda{|env| [401, {"WWW-Authenticate" => Rack::OpenID.build_header(
          :identifier => identifier,
          :return_to => callback_url,
          :required => @options[:required],
          :optional => @options[:optional],
          :method => 'post'
        )}, []]}
      end

      def identifier
        options[:identifier] || request[IDENTIFIER_URL_PARAMETER]
      end

      def request_phase
        identifier ? start : get_identifier
      end

      def start
        openid = Rack::OpenID.new(dummy_app, @store)
        response = openid.call(env)
        case env['rack.openid.response']
        when Rack::OpenID::MissingResponse, Rack::OpenID::TimeoutResponse
          fail!(:connection_failed)
        else
          response
        end
      end

      def get_identifier
        OmniAuth::Form.build(:title => 'OpenID Authentication') do
          label_field('OpenID Identifier', IDENTIFIER_URL_PARAMETER)
          input_field('url', IDENTIFIER_URL_PARAMETER)
        end.to_response
      end

      def callback_phase
        openid = Rack::OpenID.new(lambda{|env| [200,{},[]]}, @store)
        openid.call(env)
        @openid_response = env.delete('rack.openid.response')
        if @openid_response && @openid_response.status == :success
          super
        else
          fail!(:invalid_credentials)
        end
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super(), {
          'uid' => @openid_response.display_identifier,
          'user_info' => user_info(@openid_response)
        })
      end

      def user_info(response)
        sreg_user_info(response).merge(ax_user_info(response))
      end

      def sreg_user_info(response)
        sreg = ::OpenID::SReg::Response.from_success_response(response)
        return {} unless sreg
        {
          'email' => sreg['email'],
          'name' => sreg['fullname'],
          'location' => sreg['postcode'],
          'nickname' => sreg['nickname']
        }.reject{|k,v| v.nil? || v == ''}
      end

      def ax_user_info(response)
        ax = ::OpenID::AX::FetchResponse.from_success_response(response)
        return {} unless ax
        {
          'email' => ax.get_single(AX[:email]),
          'first_name' => ax.get_single(AX[:first_name]),
          'last_name' => ax.get_single(AX[:last_name]),
          'name' => (ax.get_single(AX[:name]) || [ax.get_single(AX[:first_name]), ax.get_single(AX[:last_name])].join(' ')).strip,
          'location' => ("#{ax.get_single(AX[:city])}, #{ax.get_single(AX[:state])}" if Array(ax.get_single(AX[:city])).any? && Array(ax.get_single(AX[:state])).any?),
          'nickname' => ax.get_single(AX[:nickname]),
          'urls' => ({'Website' => Array(ax.get_single(AX[:website])).first} if Array(ax.get_single(AX[:website])).any?)
        }.inject({}){|h,(k,v)| h[k] = Array(v).first; h}.reject{|k,v| v.nil? || v == ''}
      end
    end
  end
end
