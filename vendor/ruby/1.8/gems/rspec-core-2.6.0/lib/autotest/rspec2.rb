require 'autotest'
require 'rspec/core/deprecation'

class RSpecCommandError < StandardError; end

class Autotest::Rspec2 < Autotest

  SPEC_PROGRAM = File.expand_path('../../../bin/rspec', __FILE__)

  def initialize
    super()
    clear_mappings
    setup_rspec_project_mappings

    # Example for Ruby 1.8: http://rubular.com/r/AOXNVDrZpx
    # Example for Ruby 1.9: http://rubular.com/r/85ag5AZ2jP
    self.failed_results_re = /^\s*\d+\).*\n\s+(?:\e\[\d*m)?Failure.*(\n(?:\e\[\d*m)?\s+#\s(.*)?:\d+(?::.*)?(?:\e\[\d*m)?)+$/m
    self.completed_re = /\n(?:\e\[\d*m)?\d* examples?/m
  end

  def setup_rspec_project_mappings
    add_mapping(%r%^spec/.*_spec\.rb$%) { |filename, _|
      filename
    }
    add_mapping(%r%^lib/(.*)\.rb$%) { |_, m|
      ["spec/#{m[1]}_spec.rb"]
    }
    add_mapping(%r%^spec/(spec_helper|shared/.*)\.rb$%) {
      files_matching %r%^spec/.*_spec\.rb$%
    }
  end

  def consolidate_failures(failed)
    filters = new_hash_of_arrays
    failed.each do |spec, trace|
      if trace =~ /(.*spec\.rb)/
        filters[$1] << spec
      end
    end
    return filters
  end

  def make_test_cmd(files_to_test)
    files_to_test.empty? ? '' :
      "#{prefix}#{ruby}#{suffix} -S #{SPEC_PROGRAM} --tty #{normalize(files_to_test).keys.flatten.map { |f| "'#{f}'"}.join(' ')}"
  end

  def normalize(files_to_test)
    files_to_test.keys.inject({}) do |result, filename|
      result[File.expand_path(filename)] = []
      result
    end
  end

  def suffix
    using_bundler? ? "" : defined?(:Gem) ? " -rrubygems" : ""
  end

  def using_bundler?
    prefix =~ /bundle exec/
  end

  def gemfile?
    File.exist?('./Gemfile')
  end

end
