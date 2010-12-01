require 'omniauth/enterprise'
require 'net/ldap'
require 'sasl/base'
require 'sasl'
module OmniAuth
  module Strategies
    class LDAP
      include OmniAuth::Strategy
      
      autoload :Adaptor, 'omniauth/strategies/ldap/adaptor'
      @@config   =  {'name' => 'cn', 'first_name' => 'givenName', 'last_name' => 'sn', 'email' => ['mail', "email", 'userPrincipalName'],
										'phone' => ['telephoneNumber', 'homePhone', 'facsimileTelephoneNumber'],
										'mobile_number' => ['mobile', 'mobileTelephoneNumber'],
										'nickname' => ['uid', 'userid', 'sAMAccountName'],
										'title' => 'title',
										'location' => {"%0, %1, %2, %3 %4" => [['address', 'postalAddress', 'homePostalAddress', 'street', 'streetAddress'], ['l'], ['st'],['co'],['postOfficeBox']]},
										'uid' => 'dn',
										'url' => ['wwwhomepage'],
										'image' => 'jpegPhoto',
										'description' => 'description'}
      def initialize(app, title, options = {})
        super(app, options.delete(:name) || :ldap)
        @title = title
        @adaptor = OmniAuth::Strategies::LDAP::Adaptor.new(options)
      end
      
      protected
      
      def request_phase
        if env['REQUEST_METHOD'] == 'GET'
          get_credentials
        else
          perform
        end
      end

			def get_credentials
        OmniAuth::Form.build(@title) do
          text_field 'Login', 'username'
          password_field 'Password', 'password'
        end.to_response
      end
      def perform
      	begin
      		@adaptor.bind(:bind_dn => request.POST['username'], :password => request.POST['password'])
      		@ldap_user_info = @adaptor.search(:filter => Net::LDAP::Filter.eq(@adaptor.uid, request.POST['username']),:limit => 1)
      		@user_info = self.class.map_user(@@config, @ldap_user_info)
	        @env['REQUEST_METHOD'] = 'GET'
	        @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix}/#{name}/callback"
	
	        call_app!
      	rescue Exception => e
      		fail!(:invalid_credentials, e)
      	end
      end      

      def callback_phase
      	fail!(:invalid_request)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @user_info["uid"],
          'user_info' => @user_info,
          'extra' => @ldap_user_info
        })
      end
      
		  def self.map_user mapper, object
		  	user = {}
		    mapper.each do |key, value|
		      case value
		        when String
		          user[key] = object[value.downcase.to_sym].to_s if object[value.downcase.to_sym]
		        when Array
		          value.each {|v| (user[key] = object[v.downcase.to_sym].to_s; break;) if object[v.downcase.to_sym]}
		        when Hash
		        	value.map do |key1, value1|
			        	pattern = key1.dup
			        	value1.each_with_index do |v,i|
			          	part = '';
			          	v.each {|v1| (part = object[v1.downcase.to_sym].to_s; break;) if object[v1.downcase.to_sym]}
			        		pattern.gsub!("%#{i}",part||'') 
			        	end	
			        	user[key] = pattern
		       		end
		        end
		      end
		    user
		  end       
    end
  end
end
