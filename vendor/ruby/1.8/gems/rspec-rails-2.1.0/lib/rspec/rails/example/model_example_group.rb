module RSpec::Rails
  module ModelExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include RSpec::Rails::RailsExampleGroup

    included do
      metadata[:type] = :model
    end

    RSpec.configure &include_self_when_dir_matches('spec','models')
  end
end
