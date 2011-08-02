#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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

require 'chef/config'
require 'chef/cookbook_version'
require 'chef/cookbook/metadata'

class Chef
  class CookbookLoader
    
    attr_accessor :cookbook, :metadata
    
    include Enumerable
    
    def initialize()
      @cookbooks_by_name = Mash.new
      @metadata = Hash.new
      @ignore_regexes = Hash.new { |hsh, key| hsh[key] = Array.new }
      load_cookbooks
    end
    
    def load_cookbooks
      cookbook_settings = Hash.new
      [Chef::Config.cookbook_path].flatten.each do |cb_path|
        cb_path = File.expand_path(cb_path)
        Dir[File.join(cb_path, "*")].each do |cookbook|
          next unless File.directory?(cookbook)
          cookbook_name = File.basename(cookbook).to_sym
          unless cookbook_settings.has_key?(cookbook_name)
            cookbook_settings[cookbook_name] = { 
              :attribute_filenames  => Hash.new,
              :definition_filenames => Hash.new,
              :recipe_filenames     => Hash.new,
              :template_filenames   => Hash.new,
              :file_filenames       => Hash.new,
              :library_filenames    => Hash.new,
              :resource_filenames   => Hash.new,
              :provider_filenames   => Hash.new,
              :root_filenames       => Hash.new,
              :metadata_filenames   => Array.new
            }
          end
          ignore_regexes = load_ignore_file(File.join(cookbook, "ignore"))
          @ignore_regexes[cookbook_name].concat(ignore_regexes)
          
          load_files_unless_basename(
            File.join(cookbook, "attributes", "*.rb"), 
            cookbook_settings[cookbook_name][:attribute_filenames]
          )
          load_files_unless_basename(
            File.join(cookbook, "definitions", "*.rb"), 
            cookbook_settings[cookbook_name][:definition_filenames]
          )
          load_files_unless_basename(
            File.join(cookbook, "recipes", "*.rb"), 
            cookbook_settings[cookbook_name][:recipe_filenames]
          )
          load_files_unless_basename(
            File.join(cookbook, "libraries", "*.rb"),               
            cookbook_settings[cookbook_name][:library_filenames]
          )
          load_cascading_files(
            "*",
            File.join(cookbook, "templates"),
            cookbook_settings[cookbook_name][:template_filenames]
          )
          load_cascading_files(
            "*",
            File.join(cookbook, "files"),
            cookbook_settings[cookbook_name][:file_filenames]
          )
          load_cascading_files(
            "*.rb",
            File.join(cookbook, "resources"),
            cookbook_settings[cookbook_name][:resource_filenames]
          )
          load_cascading_files(
            "*.rb",
            File.join(cookbook, "providers"),
            cookbook_settings[cookbook_name][:provider_filenames]
          )
          load_files(
            "*",
            cookbook,
            cookbook_settings[cookbook_name][:root_filenames]
          )
          cookbook_settings[cookbook_name][:root_dir] = cookbook
          if File.exists?(File.join(cookbook, "metadata.json"))
            cookbook_settings[cookbook_name][:metadata_filenames] << File.join(cookbook, "metadata.json")
          end

          empty = cookbook_settings[cookbook_name].inject(true) do |all_empty, files|
            all_empty && files.last.empty?
          end

          if empty
            Chef::Log.warn "found a directory #{cookbook_name} in the cookbook path, but it contains no cookbook files. skipping."
            cookbook_settings.delete(cookbook_name)
          end
        end
      end
      remove_ignored_files_from(cookbook_settings)

      cookbook_settings.each_key do |cookbook|
        @cookbooks_by_name[cookbook] = Chef::CookbookVersion.new(cookbook)
        @cookbooks_by_name[cookbook].root_dir = cookbook_settings[cookbook][:root_dir]
        @cookbooks_by_name[cookbook].attribute_filenames = cookbook_settings[cookbook][:attribute_filenames].values
        @cookbooks_by_name[cookbook].definition_filenames = cookbook_settings[cookbook][:definition_filenames].values
        @cookbooks_by_name[cookbook].recipe_filenames = cookbook_settings[cookbook][:recipe_filenames].values
        @cookbooks_by_name[cookbook].template_filenames = cookbook_settings[cookbook][:template_filenames].values
        @cookbooks_by_name[cookbook].file_filenames = cookbook_settings[cookbook][:file_filenames].values
        @cookbooks_by_name[cookbook].library_filenames = cookbook_settings[cookbook][:library_filenames].values
        @cookbooks_by_name[cookbook].resource_filenames = cookbook_settings[cookbook][:resource_filenames].values
        @cookbooks_by_name[cookbook].provider_filenames = cookbook_settings[cookbook][:provider_filenames].values
        @cookbooks_by_name[cookbook].root_filenames = cookbook_settings[cookbook][:root_filenames].values
        @cookbooks_by_name[cookbook].metadata_filenames = cookbook_settings[cookbook][:metadata_filenames]
        @metadata[cookbook] = Chef::Cookbook::Metadata.new(@cookbooks_by_name[cookbook])
        cookbook_settings[cookbook][:metadata_filenames].each do |meta_json|
          begin
            @metadata[cookbook].from_json(IO.read(meta_json))
          rescue JSON::ParserError
            Chef::Log.fatal("Couldn't parse JSON in " + meta_json)
            raise
          end
        end
        @cookbooks_by_name[cookbook].metadata = @metadata[cookbook]
      end
    end
    
    def [](cookbook)
      if @cookbooks_by_name.has_key?(cookbook.to_sym)
        @cookbooks_by_name[cookbook.to_sym]
      else
        raise ArgumentError, "Cannot find a cookbook named #{cookbook.to_s}; did you forget to add metadata to a cookbook? (http://wiki.opscode.com/display/chef/Metadata)"
      end
    end

    def has_key?(cookbook_name)
      @cookbooks_by_name.has_key?(cookbook_name)
    end
    alias :cookbook_exists? :has_key?
    
    def each
      @cookbooks_by_name.keys.sort { |a,b| a.to_s <=> b.to_s }.each do |cname|
        yield(cname, @cookbooks_by_name[cname])
      end
    end

    def cookbook_names
      @cookbooks_by_name.keys.sort
    end

    def values
      @cookbooks_by_name.values
    end
    alias :cookbooks :values

    private
    
      def load_ignore_file(ignore_file)
        results = Array.new
        if File.exists?(ignore_file) && File.readable?(ignore_file)
          IO.foreach(ignore_file) do |line|
            next if line =~ /^#/
            next if line =~ /^\w*$/
            line.chomp!
            results << Regexp.new(line)
          end
        end
        results
      end
      
      def remove_ignored_files_from(cookbook_settings)
        file_types_to_inspect = [ :attribute_filenames, :definition_filenames, :recipe_filenames, :template_filenames, 
                                  :file_filenames, :library_filenames, :resource_filenames, :provider_filenames]
        
        @ignore_regexes.each do |cookbook_name, regexes|
          regexes.each do |regex|
            settings = cookbook_settings[cookbook_name]
            file_types_to_inspect.each do |file_type|
              settings[file_type].delete_if { |uniqname, fullpath| fullpath.match(regex) }
            end
          end
        end
      end

      def load_files(file_glob, base_path, result_hash, recursive=false)
        rm_base_path = /^#{Regexp.escape(base_path)}\/(.+)$/
        file_spec = [base_path]
        file_spec << "**" if recursive
        file_spec << file_glob
        # To handle dotfiles like .ssh
        Dir.glob(File.join(file_spec), File::FNM_DOTMATCH).each do |file|
          next if File.directory?(file)
          result_hash[rm_base_path.match(file)[1]] = file
        end
      end
      
      def load_cascading_files(file_glob, base_path, result_hash)
        load_files(file_glob, base_path, result_hash, true)
      end
      
      def load_files_unless_basename(file_glob, result_hash)
        Dir[file_glob].each do |file|
          result_hash[File.basename(file)] = file
        end
      end
      
  end
end
