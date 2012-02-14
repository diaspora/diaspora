require 'jammit'
module Jasmine
  class Config
    Jammit.reload!
    Jammit.package!
  end
end