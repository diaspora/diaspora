module OmniAuth
  
  module Test
    
    module StrategyMacros
      
      def sets_an_auth_hash
        it 'should set an auth hash' do
          last_request.env['omniauth.auth'].should be_kind_of(Hash)
        end
      end
      
      def sets_provider_to(provider)
        it "should set the provider to #{provider}" do
          (last_request.env['omniauth.auth'] || {})['provider'].should == provider
        end
      end
      
      def sets_uid_to(uid)
        it "should set the UID to #{uid}" do
          (last_request.env['omniauth.auth'] || {})['uid'].should == uid
        end
      end
      
    end
    
  end

end
