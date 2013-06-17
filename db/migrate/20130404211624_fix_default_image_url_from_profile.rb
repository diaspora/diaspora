class FixDefaultImageUrlFromProfile < ActiveRecord::Migration
  def up
    execute("UPDATE profiles SET image_url = REPLACE(image_url, 'images', 'assets'), image_url_small = REPLACE(image_url_small, 'images', 'assets'), image_url_medium = REPLACE(image_url_medium, 'images', 'assets') WHERE image_url LIKE '%images/user/default.png';")
  end

  def down
    execute("UPDATE profiles SET image_url = REPLACE(image_url, 'assets', 'images'), image_url_small = REPLACE(image_url_small, 'assets', 'images'), image_url_medium = REPLACE(image_url_medium, 'assets', 'images') WHERE image_url LIKE '%assets/user/default.png';")
  end
end
