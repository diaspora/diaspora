require 'mocha/api'

if !Test::Unit::TestCase.ancestors.include?(Mocha::API)
 
  require 'mocha/integration/test_unit/gem_version_200'
  require 'mocha/integration/test_unit/gem_version_201_to_202'
  require 'mocha/integration/test_unit/gem_version_203_to_209'
  require 'mocha/integration/test_unit/ruby_version_185_and_below'
  require 'mocha/integration/test_unit/ruby_version_186_and_above'
  
  module Test
    module Unit
      class TestCase
        
        include Mocha::API
        
        alias_method :run_before_mocha, :run
        remove_method :run
        
        test_unit_version = begin
          load 'test/unit/version.rb'
          Test::Unit::VERSION
        rescue LoadError
          '1.x'
        end

        if $options['debug']
          $stderr.puts "Detected Ruby version: #{RUBY_VERSION}"
          $stderr.puts "Detected Test::Unit version: #{test_unit_version}"
        end

        if (test_unit_version == '1.x') || (test_unit_version == '1.2.3')
          if RUBY_VERSION < '1.8.6'
            include Mocha::Integration::TestUnit::RubyVersion185AndBelow
          else
            include Mocha::Integration::TestUnit::RubyVersion186AndAbove
          end
        elsif (test_unit_version == '2.0.0')
          include Mocha::Integration::TestUnit::GemVersion200
        elsif (test_unit_version >= '2.0.1') && (test_unit_version <= '2.0.2')
          include Mocha::Integration::TestUnit::GemVersion201To202
        elsif (test_unit_version >= '2.0.3') && (test_unit_version <= '2.0.9')
          include Mocha::Integration::TestUnit::GemVersion203To209
        elsif (test_unit_version > '2.0.9')
          $stderr.puts "*** Test::Unit integration has not been verified but patching anyway ***" if $options['debug']
          include Mocha::Integration::TestUnit::GemVersion203To209
        else
          $stderr.puts "*** No Mocha integration for Test::Unit version ***" if $options['debug']
        end
        
      end
    end
  end
  
end