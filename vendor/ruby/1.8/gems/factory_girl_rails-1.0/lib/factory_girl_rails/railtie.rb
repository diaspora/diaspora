require 'factory_girl'
require 'rails'

class Factory
  class Railtie < Rails::Railtie
    config.after_initialize do
      Factory.definition_file_paths = [
        File.join(Rails.root, 'test', 'factories'),
        File.join(Rails.root, 'spec', 'factories')
      ]
      Factory.find_definitions
    end
  end
end

