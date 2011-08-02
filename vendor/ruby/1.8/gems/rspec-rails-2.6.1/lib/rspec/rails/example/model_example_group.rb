module RSpec::Rails
  module ModelExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup

    included do
      metadata[:type] = :model
    end
  end
end
