class IncreaseSimpleCaptchaLimit < ActiveRecord::Migration
  def self.up
    change_column :simple_captcha_data, :value, :string, :limit => 12
  end
  def self.down
    change_column :simple_captcha_data, :value, :string, :limit => 6
  end
end
