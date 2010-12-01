class Configuration
  Configuration::Version = '1.2.0'
  def Configuration.version() Configuration::Version end

  Path = [
    if defined? CONFIGURATION_PATH
      CONFIGURATION_PATH
    else
      ENV['CONFIGURATION_PATH']
    end
  ].compact.flatten.join(File::PATH_SEPARATOR).split(File::PATH_SEPARATOR)

  Table = Hash.new
  Error = Class.new StandardError

  module ClassMethods
    def for name, options = nil, &block
      name = name.to_s
      if Table.has_key?(name)
        if options or block
          configuration = Table[name]
          Table[name] = DSL.evaluate(configuration, options || {}, &block)
        else
          Table[name]
        end
      else
        if options or block
          Table[name] = new name, options || {}, &block
        else
          load name
        end
      end
    end

    def path *value
      return self.path = value.first unless value.empty?
      Path
    end

    def path= value
      Path.clear
      Path.replace [value].compact.flatten.join(File::PATH_SEPARATOR).split(File::PATH_SEPARATOR)
    end

    def load name
      name = name.to_s
      name = name + '.rb' unless name[%r/\.rb$/]
      key = name.sub %r/\.rb$/, ''
      load_path = $LOAD_PATH.dup
      begin
        $LOAD_PATH.replace(path + load_path)
        ::Kernel.load name
      ensure
        $LOAD_PATH.replace load_path
      end
      Table[key]
    end
  end
  send :extend, ClassMethods 

  module InstanceMethods
    attr 'name'

    def initialize *argv, &block
      options = Hash === argv.last ? argv.pop : Hash.new
      @name = argv.shift
      DSL.evaluate(self, options, &block)
    end

    def method_missing m, *a, &b
      return(Pure[@__parent].send m, *a, &b) rescue super if @__parent
      super
    end

    include Enumerable

    def each
      methods(false).each{|v| yield v }
    end

    def to_hash
      inject({}){ |h,name|
        val = __send__(name.to_sym)
        h.update name.to_sym => Configuration === val ? val.to_hash : val
      }
    end

    def update options = {}, &block
      DSL.evaluate(self, options, &block)
    end

    def dup
      ret = self.class.new @name
      each do |name|
        val = __send__ name.to_sym
        if Configuration === val
          val = val.dup
          val.instance_variable_set('@__parent', ret)
          DSL.evaluate(ret, name.to_sym => val)
        else
          DSL.evaluate(ret, name.to_sym => (val.dup rescue val))
        end
      end
      ret
    end
  end
  send :include, InstanceMethods

  class DSL
    Protected = %r/^__|^object_id$/

    instance_methods.each do |m|
      undef_method m unless m[Protected]
    end 

    Kernel.methods.each do |m|
      next if m[Protected]
      module_eval <<-code
        def #{ m }(*a, &b)
          method_missing '#{ m }', *a, &b
        end
      code
    end

    def Send(m, *a, &b)
      Method(m).call(*a, &b)
    end

    def Method m
      @__configuration.method(m)
    end

    def self.evaluate configuration, options = {}, &block
      dsl = new configuration
      Pure[dsl].instance_eval(&block) if block
      options.each{|key, value| Pure[dsl].send key, value}
      Pure[dsl].instance_eval{ @__configuration }
    end

    def initialize configuration, &block
      @__configuration = configuration
      @__singleton_class =
        class << @__configuration
          self
        end
    end

    def __configuration__
      @__configuration
    end

    undef_method(:method_missing) rescue nil
    def method_missing(m, *a, &b)
      if(a.empty? and b.nil?)
        return Pure[@__configuration].send(m, *a, &b)
      end
      if b
        raise ArgumentError unless a.empty?
        parent = @__configuration
        name = m.to_s
        configuration =
          if @__configuration.respond_to?(name) and Configuration === @__configuration.send(name)
            @__configuration.send name 
          else
            Configuration.new name
          end
        Pure[configuration].instance_eval{ @__parent = parent }
        DSL.evaluate configuration, &b
        value = configuration
      end
      unless a.empty?
        value = a.size == 1 ? a.first : a
      end
      @__singleton_class.module_eval do
        define_method(m){ value }
      end
    end

    verbose = $VERBOSE
    begin
      $VERBOSE = nil
      def object_id(*args)
        unless args.empty?
          verbose = $VERBOSE
          begin
            $VERBOSE = nil
            define_method(:object_id){ args.first }
          ensure
            $VERBOSE = verbose
          end
        else
          return Pure[@__configuration].object_id
        end
      end
    ensure
      $VERBOSE = verbose
    end
  end

  class Pure
    Instance_Methods = Hash.new
    Protected = %r/^__|^object_id$/

    ::Object.instance_methods.each do |m|
      Instance_Methods[m.to_s] = ::Object.instance_method m
      undef_method m unless m[Protected]
    end 

    def method_missing m, *a, &b
      Instance_Methods[m.to_s].bind(@object).call(*a, &b)
    end

    def initialize object
      @object = object
    end

    def Pure.[] object
      new object
    end
  end
end

def Configuration(*a, &b)
  if a.empty? and b.nil?
    const_get :Configuration
  else
    Configuration.new(*a, &b)
  end
end

