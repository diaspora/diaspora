module RSpec::Rails
  module ModuleInclusion
    # Deprecated as of rspec-rails-2.4
    # Will be removed from rspec-rails-3.0
    #
    # This was never intended to be a public API and is no longer needed
    # internally. As it happens, there are a few blog posts citing its use, so
    # I'm leaving it here, but deprecated.
    def include_self_when_dir_matches(*path_parts)
        instead = <<-INSTEAD


    RSpec.configure do |c|
      c.include self, :example_group => {
        :file_path => /#{path_parts.join('\/')}/
      }
    end

INSTEAD
      lambda do |c|
        RSpec.deprecate('include_self_when_dir_matches', instead, 'rails-3.0')
        c.include self, :example_group => {
          :file_path => Regexp.compile(path_parts.join('[\\\/]'))
        }
      end
    end
  end
end
