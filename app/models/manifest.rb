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

  validates :app_name, presence: true
  validates :app_description, length: { maximum: 500 }
  validates :app_id, presence: true
  validates :callback_url, presence: true, format: URI::regexp(%w(http https))
  validates :redirect_url, presence: true, format: URI::regexp(%w(http https))

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
      :access => self.scopes
    }
  end

  def create_manifest_json
    manifest_hash = self.manifest_hash
    manifest_hash[:signed_jwt] = self.signed_jwt
    manifest_hash.to_json
  end

  private

  def generate_app_id
    self.app_id = SecureRandom.uuid
  end
end
