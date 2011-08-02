module OAuth2::Provider::Models::ActiveRecord
  autoload :Authorization, 'oauth2/provider/models/active_record/authorization'
  autoload :AccessToken, 'oauth2/provider/models/active_record/access_token'
  autoload :AuthorizationCode, 'oauth2/provider/models/active_record/authorization_code'
  autoload :Client, 'oauth2/provider/models/active_record/client'

  mattr_accessor :client_table_name
  self.client_table_name = 'oauth_clients'

  mattr_accessor :access_token_table_name
  self.access_token_table_name = 'oauth_access_tokens'

  mattr_accessor :authorization_code_table_name
  self.authorization_code_table_name = 'oauth_authorization_codes'

  mattr_accessor :authorization_table_name
  self.authorization_table_name = 'oauth_authorizations'

  def self.activate(options = {})
    OAuth2::Provider.client_class_name ||= "OAuth2::Provider::Models::ActiveRecord::Client"
    OAuth2::Provider.access_token_class_name ||= "OAuth2::Provider::Models::ActiveRecord::AccessToken"
    OAuth2::Provider.authorization_code_class_name ||= "OAuth2::Provider::Models::ActiveRecord::AuthorizationCode"
    OAuth2::Provider.authorization_class_name ||= "OAuth2::Provider::Models::ActiveRecord::Authorization"

    OAuth2::Provider.client_class.set_table_name client_table_name
    OAuth2::Provider.access_token_class.set_table_name access_token_table_name
    OAuth2::Provider.authorization_code_class.set_table_name authorization_code_table_name
    OAuth2::Provider.authorization_class.set_table_name authorization_table_name
  end
end