module RSpec
  module Core
    module ConstMissing
      def const_missing(name)
        case name
        when :Rspec, :Spec
          RSpec.warn_deprecation <<-WARNING
*****************************************************************
DEPRECATION WARNING: you are using a deprecated constant that will
be removed from a future version of RSpec.

#{caller(0)[2]}

* #{name} is deprecated.
* RSpec is the new top-level module in RSpec-2
***************************************************************
WARNING
          RSpec
        else
          super(name)
        end
      end
    end
  end

  module Runner
    def self.configure(&block)
      RSpec.deprecate("Spec::Runner.configure", "RSpec.configure")
      RSpec.configure(&block)
    end
  end

  module Rake
    def self.const_missing(name)
      case name
      when :SpecTask
        RSpec.deprecate("Spec::Rake::SpecTask", "RSpec::Core::RakeTask")
        require 'rspec/core/rake_task'
        RSpec::Core::RakeTask
      else
        super(name)
      end
    end

  end
end

Object.extend(RSpec::Core::ConstMissing)
