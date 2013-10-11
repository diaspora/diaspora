class Manifest < ActiveRecord::Base

  serialize :scopes, Array

  belongs_to :dev, :class_name => 'User'

  attr_accessible :app_description,
                  :app_name,
                  :app_id,
                  :app_version,
                  :callback_url,
                  :redirect_url,
                  :manifest_ver,
                  :signed_jwt,
                  :scopes

  before_validation :generate_app_id, :on => :create
  before_validation :sign, :on => :create

  validates :app_name, presence: true
  validates :app_description, length: { maximum: 500 }
  validates :app_id, presence: true
  validates :callback_url, presence: true, format: URI::regexp(%w(http https))
  validates :redirect_url, presence: true, format: URI::regexp(%w(http https))
  validates :signed_jwt, presence: true

  def manifest_hash
    {
      :dev_handle => self.dev.diaspora_handle,
      :manifest_version => "1.0",
      :app_details => {
        :name => self.app_name,
        :id => self.app_id,
        :description => self.app_description,
        :version => self.app_version
      },
      :callback_url => self.callback_url,
      :redirect_url => self.redirect_url,
      :access => self.scopes,
      :signed_jwt => self.signed_jwt
    }
  end

  def create_manifest_json
    manifest_hash = self.manifest_hash
    manifest_hash.to_json
  end
    
  def sign
    private_key = self.dev.serialized_private_key
    self.signed_jwt = JWT.encode(manifest_hash, OpenSSL::PKey::RSA.new(private_key), "RS256")
  end

  def verify jwt
    developer_handle = self.devloper_handle_from_jwt jwt
    person = Webfinger.new(developer_handle).fetch
    JWT.decode(self.signed_jwt, person.public_key)
  end

  def self.by_signed_jwt jwt
    manifest = Manifest.new
    begin
     payload = JWT.decode(jwt, nil, false)
    rescue JWT::DecodeError => e
     return nil
    end
    manifest.callback_url = payload["callback_url"]
    manifest.redirect_url = payload["redirect_url"]
    manifest.scopes = payload["access"]
    manifest.app_id = payload["app_details"]["id"]
    manifest.app_name = payload["app_details"]["name"]
    manifest.app_description = payload["app_details"]["description"]
    manifest.app_version = payload["app_details"]["version"]
    manifest.signed_jwt = jwt
    manifest
  end

  def devloper_handle_from_jwt jwt
    begin
     payload = JWT.decode(jwt, nil, false)
     return payload["dev_handle"]
    rescue JWT::DecodeError => e
     return nil
    end
  end

  private

  def generate_app_id
    self.app_id = SecureRandom.uuid
  end
end
