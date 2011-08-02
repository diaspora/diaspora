require 'fileutils'

module YARD
  # The data store for the {Registry}.
  #
  # @see Registry
  # @see Serializers::YardocSerializer
  class RegistryStore
    attr_reader :proxy_types, :file, :checksums

    def initialize
      @file = nil
      @checksums = {}
      @store = {}
      @proxy_types = {}
      @notfound = {}
      @loaded_objects = 0
      @available_objects = 0
      @store[:root] = CodeObjects::RootObject.allocate
      @store[:root].send(:initialize, nil, :root)
    end

    # Gets a {CodeObjects::Base} from the store
    #
    # @param [String, Symbol] key the path name of the object to look for.
    #   If it is empty or :root, returns the {#root} object.
    # @return [CodeObjects::Base, nil] a code object or nil if none is found
    def get(key)
      key = :root if key == ''
      key = key.to_sym
      return @store[key] if @store[key]
      return if @loaded_objects >= @available_objects

      # check disk
      return if @notfound[key]
      if obj = @serializer.deserialize(key)
        @loaded_objects += 1
        put(key, obj)
      else
        @notfound[key] = true
        nil
      end
    end

    # Associates an object with a path
    # @param [String, Symbol] key the path name (:root or '' for root object)
    # @param [CodeObjects::Base] value the object to store
    # @return [CodeObjects::Base] returns +value+
    def put(key, value)
      if key == ''
        @store[:root] = value
      else
        @notfound.delete(key.to_sym)
        @store[key.to_sym] = value
      end
    end

    alias [] get
    alias []= put

    def delete(key) @store.delete(key.to_sym) end

    # Gets all path names from the store. Loads the entire database
    # if +reload+ is +true+
    #
    # @param [Boolean] reload if false, does not load the entire database
    #   before a lookup.
    # @return [Array<Symbol>] the path names of all the code objects
    def keys(reload = false) load_all if reload; @store.keys end

    # Gets all code objects from the store. Loads the entire database
    # if +reload+ is +true+
    #
    # @param [Boolean] reload if false, does not load the entire database
    #   before a lookup.
    # @return [Array<CodeObjects::Base>] all the code objects
    def values(reload = false) load_all if reload; @store.values end

    # @return [CodeObjects::RootObject] the root object
    def root; @store[:root] end

    # @param [String, nil] file the name of the yardoc db to load
    # @return [Boolean] whether the database was loaded
    def load(file = nil)
      @file = file
      @store = {}
      @proxy_types = {}
      @notfound = {}
      @serializer = Serializers::YardocSerializer.new(@file)
      load_yardoc
    end

    # Loads the .yardoc file and loads all cached objects into memory
    # automatically.
    #
    # @param [String, nil] file the name of the yardoc db to load
    # @return [Boolean] whether the database was loaded
    # @see #load_all
    # @since 0.5.1
    def load!(file = nil)
      if load(file)
        load_all
        true
      else
        false
      end
    end

    # Loads all cached objects into memory
    # @return [void]
    def load_all
      return unless @file
      return if @loaded_objects >= @available_objects
      log.debug "Loading entire database: #{@file} ..."
      objects = []

      all_disk_objects.sort_by {|x| x.size }.each do |path|
        if obj = @serializer.deserialize(path, true)
          objects << obj
        end
      end
      objects.each do |obj|
        put(obj.path, obj)
      end
      @loaded_objects += objects.size
      log.debug "Loaded database (file='#{@file}' count=#{objects.size} total=#{@available_objects})"
    end

    # Saves the database to disk
    # @param [Boolean] merge if true, merges the data in memory with the
    #   data on disk, otherwise the data on disk is deleted.
    # @param [String, nil] file if supplied, the name of the file to save to
    # @return [Boolean] whether the database was saved
    def save(merge = true, file = nil)
      if file && file != @file
        @file = file
        @serializer = Serializers::YardocSerializer.new(@file)
      end
      destroy unless merge

      sdb = Registry.single_object_db
      if sdb == true || (sdb == nil && keys.size < 3000)
        @serializer.serialize(@store)
      else
        values(false).each do |object|
          @serializer.serialize(object)
        end
      end
      write_proxy_types
      write_checksums
      true
    end

    # Deletes the .yardoc database on disk
    #
    # @param [Boolean] force if force is not set to true, the file/directory
    #   will only be removed if it ends with .yardoc. This helps with
    #   cases where the directory might have been named incorrectly.
    # @return [Boolean] true if the .yardoc database was deleted, false
    #   otherwise.
    def destroy(force = false)
      if (!force && file =~ /\.yardoc$/) || force
        if File.file?(@file)
          # Handle silent upgrade of old .yardoc format
          File.unlink(@file)
        elsif File.directory?(@file)
          FileUtils.rm_rf(@file)
        end
        true
      else
        false
      end
    end

    protected

    def objects_path
      @serializer.objects_path
    end

    def proxy_types_path
      @serializer.proxy_types_path
    end

    def checksums_path
      @serializer.checksums_path
    end

    def load_yardoc
      return false unless @file
      if File.directory?(@file) # new format
        @loaded_objects = 0
        @available_objects = all_disk_objects.size
        load_proxy_types
        load_checksums
        load_root
        true
      elsif File.file?(@file) # old format
        load_yardoc_old
        true
      else
        false
      end
    end

    private

    def load_yardoc_old
      @store, @proxy_types = *Marshal.load(File.read_binary(@file))
    end

    def load_proxy_types
      return unless File.file?(proxy_types_path)
      @proxy_types = Marshal.load(File.read_binary(proxy_types_path))
    end

    def load_checksums
      return unless File.file?(checksums_path)
      lines = File.readlines(checksums_path).map do |line|
        line.strip.split(/\s+/)
      end
      @checksums = Hash[lines]
    end

    def load_root
      if root = @serializer.deserialize('root')
        @loaded_objects += 1
        if root.is_a?(Hash) # single object db
          log.debug "Loading single object DB from .yardoc"
          @loaded_objects += (root.keys.size - 1)
          @store = root
        else # just the root object
          @store[:root] = root
        end
      end
    end

    def all_disk_objects
      Dir.glob(File.join(objects_path, '**/*')).select {|f| File.file?(f) }
    end

    def write_proxy_types
      File.open!(proxy_types_path, 'wb') {|f| f.write(Marshal.dump(@proxy_types)) }
    end

    def write_checksums
      File.open!(checksums_path, 'w') do |f|
        @checksums.each {|k, v| f.puts("#{k} #{v}") }
      end
    end
  end
end