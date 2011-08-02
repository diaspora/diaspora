require 'mongoid'

class ExampleResourceOwner
  include Mongoid::Document

  field :username
  field :password

  references_many :authorizations, :class_name => "OAuth2::Provider::Models::Mongoid::Authorization"

  def self.authenticate_with_username_and_password(username, password)
    where(:username => username, :password => password).first
  end
end

OAuth2::Provider.configure do |config|
  config.backend = :mongoid
  config.resource_owner_class_name = 'ExampleResourceOwner'
end

Mongoid.configure do |config|
  config.from_hash(
    "host" => "127.0.0.1",
    "autocreate_indexes" => false,
    "allow_dynamic_fields" => true,
    "include_root_in_json" => false,
    "parameterize_keys" => true,
    "persist_in_safe_mode" => true,
    "raise_not_found_error" => true,
    "reconnect_time" => 3,
    "use_activesupport_time_zone" => true,
    "database" => "oauth2_test"
  )
end