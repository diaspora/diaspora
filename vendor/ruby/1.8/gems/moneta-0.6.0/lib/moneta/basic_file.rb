#
#  Basic File Store
#  by Hampton Catlin
#
#  This cache simply uses a directory that it creates
#  and manages to keep your file stores.
#
#  Specify :skip_expires => true if you aren't using 
#  expiration as this will slightly decrease your file size
#  and memory footprint of the library
#
#  You can optionally also specify a :namespace
#  option that will create a subfolder.
#


require 'fileutils'
require File.join(File.dirname(__FILE__), "..", "moneta.rb")

module Moneta
  class BasicFile
    include Defaults
    
    def initialize(options = {})
      @namespace = options[:namespace]
      @directory = ::File.join(options[:path], @namespace.to_s)
      
      @expires = !options[:skip_expires]

      ensure_directory_created(@directory)
    end
    
    def key?(key)
      !self[key].nil?
    end
    
    alias has_key? key?
    
    def [](key)
      if ::File.exist?(path(key))
        data = raw_get(key)
        if @expires
          if data[:expires_at].nil? || data[:expires_at] > Time.now
            data[:value]
          else
            delete!(key)
          end
        end
      end
    end
    
    def raw_get(key)
      Marshal.load(::File.read(path(key)))
    end
    
    def []=(key, value)
      store(key, value)
    end
    
    def store(key, value, options = {})
      ensure_directory_created(::File.dirname(path(key)))
      ::File.open(path(key), "w") do |file|
        if @expires
          data = {:value => value}
          if options[:expires_in]
            data[:expires_at] = Time.now + options[:expires_in]
          end
          contents = Marshal.dump(data)
        else
          contents = Marshal.dump(value)
        end
        file.puts(contents)
      end
    end
    
    def update_key(key, options)
      store(key, self[key], options)
    end
    
    def delete!(key)
      FileUtils.rm(path(key))
      nil
    rescue Errno::ENOENT
    end
          
    def delete(key)
      value = self[key]
      delete!(key)
      value
    end
          
    def clear
      FileUtils.rm_rf(@directory)
      FileUtils.mkdir(@directory)
    end
    
    private
    def path(key)
      ::File.join(@directory, key.to_s)
    end
    
    def ensure_directory_created(directory_path)
      if ::File.file?(directory_path)
        raise StandardError, "The path you supplied #{directory_path} is a file"
      elsif !::File.exists?(directory_path)
        FileUtils.mkdir_p(directory_path)
      end
    end
      
  end
end