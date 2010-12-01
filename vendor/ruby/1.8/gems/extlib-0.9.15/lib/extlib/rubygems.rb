# this is a temporary workaround until rubygems Does the Right thing here
require 'rubygems'
module Gem
  class SourceIndex

    # This is resolved in 1.1
    if Version.new(RubyGemsVersion) < Version.new("1.1")

      # Overwrite this so that a gem of the same name and version won't push one
      # from the gems directory out entirely.
      #
      # @param gem_spec<Gem::Specification> The specification of the gem to add.
      def add_spec(gem_spec)
        unless gem_spec.instance_variable_get("@loaded_from") &&
          @gems[gem_spec.full_name].is_a?(Gem::Specification) &&
          @gems[gem_spec.full_name].installation_path ==
            File.join(defined?(Merb) && Merb.respond_to?(:root) ? Merb.root : Dir.pwd,"gems")

          @gems[gem_spec.full_name] = gem_spec
        end
      end

    end

  end

  class Specification

    # Overwrite this so that gems in the gems directory get preferred over gems
    # from any other location. If there are two gems of different versions in
    # the gems directory, the later one will load as usual.
    #
    # @return [Array<Array>] The object used for sorting gem specs.
    def sort_obj
      [@name, installation_path == File.join(defined?(Merb) && Merb.respond_to?(:root) ? Merb.root : Dir.pwd,"gems") ? 1 : -1, @version.to_ints, @new_platform == Gem::Platform::RUBY ? -1 : 1]
    end
  end
end
