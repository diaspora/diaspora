module YARD
  # Stubs marshal dumps and acts a delegate class for an object by path
  #
  # @private
  class StubProxy
    instance_methods.each {|m| undef_method(m) unless m.to_s =~ /^__|^object_id$/ }

    def _dump(depth) @path end
    def self._load(str) new(str) end
    def hash; @path.hash end

    def initialize(path, transient = false)
      @path = path
      @transient = transient
    end

    def method_missing(meth, *args, &block)
      return true if meth == :respond_to? && args.first == :_dump
      @object = nil if @transient
      @object ||= Registry.at(@path)
      @object.send(meth, *args, &block)
    rescue NoMethodError => e
      e.backtrace.delete_if {|l| l[0, __FILE__.size] == __FILE__ }
      raise
    end
  end

  module Serializers
    class YardocSerializer < FileSystemSerializer
      def initialize(yfile)
        super(:basepath => yfile, :extension => 'dat')
      end

      def objects_path; File.join(basepath, 'objects') end
      def proxy_types_path; File.join(basepath, 'proxy_types') end
      def checksums_path; File.join(basepath, 'checksums') end

      def serialized_path(object)
        path = case object
        when String, Symbol
          object = object.to_s
          if object =~ /#/
            object += '_i'
          elsif object =~ /\./
            object += '_c'
          end
          object.split(/::|\.|#/).map do |p|
            p.gsub(/[^\w\.-]/) do |x|
              encoded = '_'

              x.each_byte { |b| encoded << ("%X" % b) }
              encoded
            end
          end.join('/') + '.' + extension
        when YARD::CodeObjects::RootObject
          'root.dat'
        else
          super(object)
        end
        File.join('objects', path)
      end

      def serialize(object)
        if Hash === object
          super(object[:root], dump(object)) if object[:root]
        else
          super(object, dump(object))
        end
      end

      def deserialize(path, is_path = false)
        path = File.join(basepath, serialized_path(path)) unless is_path
        if File.file?(path)
          log.debug "Deserializing #{path}..."
          Marshal.load(File.read_binary(path))
        else
          log.debug "Could not find #{path}"
          nil
        end
      end

      private

      def dump(object)
        object = internal_dump(object, true) unless object.is_a?(Hash)
        Marshal.dump(object)
      end

      def internal_dump(object, first_object = false)
        if !first_object && object.is_a?(CodeObjects::Base) &&
            !(Tags::OverloadTag === object)
          return StubProxy.new(object.path)
        end

        if object.is_a?(Hash) || object.is_a?(Array) ||
            object.is_a?(CodeObjects::Base) ||
            object.instance_variables.size > 0
          object = object.dup
        end

        object.instance_variables.each do |ivar|
          ivar_obj = object.instance_variable_get(ivar)
          ivar_obj_dump = internal_dump(ivar_obj)
          object.instance_variable_set(ivar, ivar_obj_dump)
        end

        case object
        when Hash
          list = object.map do |k, v|
            [k, v].map {|item| internal_dump(item) }
          end
          object.replace(Hash[list])
        when Array
          list = object.map {|item| internal_dump(item) }
          object.replace(list)
        end

        object
      end
    end
  end
end