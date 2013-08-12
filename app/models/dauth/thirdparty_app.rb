class Dauth::ThirdpartyApp < ActiveRecord::Base

  has_many :refresh_tokens, :class_name => 'Dauth::RefreshToken', :foreign_key => :app_id

  attr_accessible :app_id,
                  :name,
                  :description,
                  :dev_handle,
                  :homepage_url

  validates :app_id, presence: true, uniqueness: true
  validates :dev_handle, presence: true 
end
