class CreateSimpleCaptchaData < ActiveRecord::Migration[4.2]
  def self.up
    create_table :simple_captcha_data do |t|
      t.string :key, :limit => 40
      t.string :value, :limit => 6
      t.timestamps
    end
    
    add_index :simple_captcha_data, :key, :name => "idx_key"
  end

  def self.down
    drop_table :simple_captcha_data
  end
end
