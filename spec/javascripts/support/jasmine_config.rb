require 'jammit'
module Jasmine
  class Config
 
    Jammit.reload!
    Jammit.package!({ :config_path => Rails.root.join("config", "assets_test.yml")})
 
  end
end