#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2008, 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/package'
require 'chef/mixin/command'
require 'chef/resource/package'

# Class methods on Gem are defined in rubygems
require 'rubygems'
# Ruby 1.9's gem_prelude can interact poorly with loading the full rubygems
# explicitly like this. Make sure rubygems/specification is always last in this
# list
require 'rubygems/version'
require 'rubygems/dependency'
require 'rubygems/spec_fetcher'
require 'rubygems/platform'
require 'rubygems/format'
require 'rubygems/dependency_installer'
require 'rubygems/uninstaller'
require 'rubygems/specification'

class Chef
  class Provider
    class Package
      class Rubygems < Chef::Provider::Package
        class GemEnvironment
          # HACK: trigger gem config load early. Otherwise it can get lazy
          # loaded during operations where we've set Gem.sources to an
          # alternate value and overwrite it with the defaults.
          Gem.configuration

          DEFAULT_UNINSTALLER_OPTS = {:ignore => true, :executables => true}

          ##
          # The paths where rubygems should search for installed gems.
          # Implemented by subclasses.
          def gem_paths
            raise NotImplementedError
          end

          ##
          # A rubygems source index containing the list of gemspecs for all
          # available gems in the gem installation.
          # Implemented by subclasses
          # === Returns
          # Gem::SourceIndex
          def gem_source_index
            raise NotImplementedError
          end

          ##
          # Lists the installed versions of +gem_name+, constrained by the
          # version spec in +gem_dep+
          # === Arguments
          # Gem::Dependency   +gem_dep+ is a Gem::Dependency object, its version
          #                   specification constrains which gems are returned.
          # === Returns
          # [Gem::Specification]  an array of Gem::Specification objects
          def installed_versions(gem_dep)
            gem_source_index.search(gem_dep)
          end

          ##
          # Yields to the provided block with rubygems' source list set to the
          # list provided. Always resets the list when the block returns or
          # raises an exception.
          def with_gem_sources(*sources)
            sources.compact!
            original_sources = Gem.sources
            Gem.sources = sources unless sources.empty?
            yield
          ensure
            Gem.sources = original_sources
          end

          ##
          # Determines the candidate version for a gem from a .gem file on disk
          # and checks if it matches the version contraints in +gem_dependency+
          # === Returns
          # Gem::Version  a singular gem version object is returned if the gem
          #               is available
          # nil           returns nil if the gem on disk doesn't match the
          #               version constraints for +gem_dependency+
          def candidate_version_from_file(gem_dependency, source)
            spec = Gem::Format.from_file_by_path(source).spec
            if spec.satisfies_requirement?(gem_dependency)
              logger.debug {"found candidate gem version #{spec.version} from local gem package #{source}"}
              spec.version
            else
              # This is probably going to end badly...
              logger.warn { "The gem package #{source} does not satisfy the requirements #{gem_dependency.to_s}" }
              nil
            end
          end

          ##
          # Finds the newest version that satisfies the constraints of
          # +gem_dependency+. The version is determined from the cache or a
          # round-trip to the server as needed. The architecture and gem
          # sources will be set before making the query.
          # === Returns
          # Gem::Version  a singular gem version object is returned if the gem
          #               is available
          # nil           returns nil if the gem could not be found
          def candidate_version_from_remote(gem_dependency, *sources)
            raise NotImplementedError
          end

          ##
          # Find the newest gem version available from Gem.sources that satisfies
          # the constraints of +gem_dependency+
          def find_newest_remote_version(gem_dependency, *sources)
            # DependencyInstaller sorts the results such that the last one is
            # always the one it considers best.
            spec_with_source = dependency_installer.find_gems_with_sources(gem_dependency).last

            spec = spec_with_source && spec_with_source[0]
            version = spec && spec_with_source[0].version
            if version
              logger.debug { "Found gem #{spec.name} version #{version} for platform #{spec.platform} from #{spec_with_source[1]}" }
              version
            else
              source_list = sources.compact.empty? ? "[#{Gem.sources.join(', ')}]" : "[#{sources.join(', ')}]"
              logger.warn { "Failed to find gem #{gem_dependency} from #{source_list}" }
              nil
            end
          end

          ##
          # Installs a gem via the rubygems ruby API.
          # === Options
          # :sources    rubygems servers to use
          # Other options are passed to Gem::DependencyInstaller.new
          def install(gem_dependency, options={})
            with_gem_sources(*options.delete(:sources)) do
              with_correct_verbosity do
                dependency_installer(options).install(gem_dependency)
              end
            end
          end

          ##
          # Uninstall the gem +gem_name+ via the rubygems ruby API. If
          # +gem_version+ is provided, only that version will be uninstalled.
          # Otherwise, all versions are uninstalled.
          # === Options
          # Options are passed to Gem::Uninstaller.new
          def uninstall(gem_name, gem_version=nil, opts={})
            gem_version ? opts[:version] = gem_version : opts[:all] = true
            with_correct_verbosity do
              uninstaller(gem_name, opts).uninstall
            end
          end

          ##
          # Set rubygems' user interaction to ConsoleUI or SilentUI depending
          # on our current debug level
          def with_correct_verbosity
            Gem::DefaultUserInteraction.ui = Chef::Log.debug? ? Gem::ConsoleUI.new : Gem::SilentUI.new
            yield
          end

          def dependency_installer(opts={})
            Gem::DependencyInstaller.new(opts)
          end

          def uninstaller(gem_name, opts={})
            Gem::Uninstaller.new(gem_name, DEFAULT_UNINSTALLER_OPTS.merge(opts))
          end

          private

          def logger
            Chef::Log.logger
          end

        end

        class CurrentGemEnvironment < GemEnvironment

          def gem_paths
            Gem.path
          end

          def gem_source_index
            Gem.source_index
          end

          def candidate_version_from_remote(gem_dependency, *sources)
            with_gem_sources(*sources) do
              find_newest_remote_version(gem_dependency, *sources)
            end
          end

        end

        class AlternateGemEnvironment < GemEnvironment
          JRUBY_PLATFORM = /(:?universal|x86_64|x86)\-java\-[0-9\.]+/
          
          def self.gempath_cache
            @gempath_cache ||= {}
          end

          def self.platform_cache
            @platform_cache ||= {}
          end

          include Chef::Mixin::ShellOut

          attr_reader :gem_binary_location

          def initialize(gem_binary_location)
            @gem_binary_location = gem_binary_location
          end

          def gem_paths
            if self.class.gempath_cache.key?(@gem_binary_location)
              self.class.gempath_cache[@gem_binary_location]
            else
              # shellout! is a fork/exec which won't work on windows
              shell_style_paths = shell_out!("#{@gem_binary_location} env gempath").stdout
              # on windows, the path separator is (usually? always?) semicolon
              paths = shell_style_paths.split(::File::PATH_SEPARATOR).map { |path| path.strip }
              self.class.gempath_cache[@gem_binary_location] = paths
            end
          end

          def gem_source_index
            @source_index ||= Gem::SourceIndex.from_gems_in(*gem_paths.map { |p| p + '/specifications' })
          end

          ##
          # Attempt to detect the correct platform settings for the target gem
          # environment.
          #
          # In practice, this only makes a difference if different versions are
          # available depending on platform, and only if the target gem
          # environment has a radically different platform (i.e., jruby), so we
          # just try to detect jruby and fall back to the current platforms
          # (Gem.platforms) if we don't detect it.
          #
          # === Returns
          # [String|Gem::Platform] returns an array of Gem::Platform-compatible
          # objects, i.e., Strings that are valid for Gem::Platform or actual
          # Gem::Platform objects.
          def gem_platforms
            if self.class.platform_cache.key?(@gem_binary_location)
              self.class.platform_cache[@gem_binary_location]
            else
              gem_environment = shell_out!("#{@gem_binary_location} env").stdout
              if jruby = gem_environment[JRUBY_PLATFORM]
                self.class.platform_cache[@gem_binary_location] = ['ruby', Gem::Platform.new(jruby)]
              else
                self.class.platform_cache[@gem_binary_location] = Gem.platforms
              end
            end
          end

          def with_gem_platforms(*alt_gem_platforms)
            alt_gem_platforms.flatten!
            original_gem_platforms = Gem.platforms
            Gem.platforms = alt_gem_platforms
            yield
          ensure
            Gem.platforms = original_gem_platforms
          end

          def candidate_version_from_remote(gem_dependency, *sources)
            with_gem_sources(*sources) do
              with_gem_platforms(*gem_platforms) do
                find_newest_remote_version(gem_dependency, *sources)
              end
            end
          end

        end

        include Chef::Mixin::ShellOut

        attr_reader :gem_env

        def logger
          Chef::Log.logger
        end

        def initialize(new_resource, run_context=nil)
          super
          if new_resource.gem_binary
            if new_resource.options && new_resource.options.kind_of?(Hash)
              msg =  "options cannot be given as a hash when using an explicit gem_binary\n"
              msg << "in #{new_resource} from #{new_resource.source_line}"
              raise ArgumentError, msg
            end
            @gem_env = AlternateGemEnvironment.new(new_resource.gem_binary)
          else
            @gem_env = CurrentGemEnvironment.new
          end
        end

        def gem_dependency
          Gem::Dependency.new(@new_resource.package_name, @new_resource.version)
        end

        def source_is_remote?
          return true if @new_resource.source.nil?
          URI.parse(@new_resource.source).absolute?
        end

        def current_version
          #raise 'todo'
          # If one or more matching versions are installed, the newest of them
          # is the current version
          if !matching_installed_versions.empty?
            gemspec = matching_installed_versions.last
            logger.debug { "Found installed gem #{gemspec.name} version #{gemspec.version} matching #{gem_dependency}"}
            gemspec
          # If no version matching the requirements exists, the latest installed
          # version is the current version.
          elsif !all_installed_versions.empty?
            gemspec = all_installed_versions.last
            logger.debug { "Newest installed version of gem #{gemspec.name} is #{gemspec.version}" }
            gemspec
          else
            logger.debug { "No installed version found for #{gem_dependency.to_s}"}
            nil
          end
        end

        def matching_installed_versions
          @matching_installed_versions ||= @gem_env.installed_versions(gem_dependency)
        end

        def all_installed_versions
          @all_installed_versions ||= begin
            @gem_env.installed_versions(Gem::Dependency.new(gem_dependency.name, '>= 0'))
          end
        end

        def gem_sources
          @new_resource.source ? [@new_resource.source, 'http://rubygems.org'] : nil
        end

        def load_current_resource
          @current_resource = Chef::Resource::Package::GemPackage.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          if current_spec = current_version
            @current_resource.version(current_spec.version.to_s)
          end
          @current_resource
        end

        def candidate_version
          @candidate_version ||= begin
            if target_version_already_installed?
              nil
            elsif source_is_remote?
              @gem_env.candidate_version_from_remote(gem_dependency, *gem_sources).to_s
            else
              @gem_env.candidate_version_from_file(gem_dependency, @new_resource.source).to_s
            end
          end
        end

        def target_version_already_installed?
          return false unless @current_resource && @current_resource.version
          return false if @current_resource.version.nil?
          # in the future we could support squiggly requirements like "~> 1.2.0"
          # for now, the behavior when using anything other than exact 
          # requirements is undefined.
          Gem::Requirement.new(@new_resource.version).satisfied_by?(Gem::Version.new(@current_resource.version))
        end

        ##
        # Installs the gem, using either the gems API or shelling out to `gem`
        # according to the following criteria:
        # 1. Use gems API (Gem::DependencyInstaller) by default
        # 2. shell out to `gem install` when a String of options is given
        # 3. use gems API with options if a hash of options is given
        def install_package(name, version)
          if source_is_remote? && @new_resource.gem_binary.nil?
            if @new_resource.options.nil?
              @gem_env.install(gem_dependency, :sources => gem_sources)
            elsif @new_resource.options.kind_of?(Hash)
              options = @new_resource.options
              options[:sources] = gem_sources
              @gem_env.install(gem_dependency, options)
            else
              install_via_gem_command(name, version)
            end
          elsif @new_resource.gem_binary.nil?
            @gem_env.install(@new_resource.source)
          else
            install_via_gem_command(name,version)
          end
          true
        end

        def gem_binary_path
          @new_resource.gem_binary || 'gem'
        end

        def install_via_gem_command(name, version)
          src = @new_resource.source && "  --source=#{@new_resource.source} --source=http://rubygems.org"
          shell_out!("#{gem_binary_path} install #{name} -q --no-rdoc --no-ri -v \"#{version}\"#{src}#{opts}", :env=>nil)
        end

        def upgrade_package(name, version)
          install_package(name, version)
        end

        def remove_package(name, version)
          if @new_resource.gem_binary.nil?
            if @new_resource.options.nil?
              @gem_env.uninstall(name, version)
            elsif @new_resource.options.kind_of?(Hash)
              @gem_env.uninstall(name, version, @new_resource.options)
            else
              uninstall_via_gem_command(name, version)
            end
          else
            uninstall_via_gem_command(name, version)
          end
        end

        def uninstall_via_gem_command(name, version)
          if version
            shell_out!("#{gem_binary_path} uninstall #{name} -q -x -I -v \"#{version}\"#{opts}", :env=>nil)
          else
            shell_out!("#{gem_binary_path} uninstall #{name} -q -x -I -a#{opts}", :env=>nil)
          end
        end

        def purge_package(name, version)
          remove_package(name, version)
        end

        private

        def opts
          expand_options(@new_resource.options)
        end

      end
    end
  end
end
