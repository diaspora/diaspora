class FSSM::Path
  def initialize(path=nil, glob=nil, &block)
    set_path(path || '.')
    set_glob(glob || '**/*')
    init_callbacks

    if block_given?
      if block.arity == 1
        block.call(self)
      else
        self.instance_eval(&block)
      end
    end
  end

  def to_s
    @path.to_s
  end

  def to_pathname
    @path
  end

  def glob(value=nil)
    return @glob if value.nil?
    set_glob(value)
  end

  def create(callback_or_path=nil, &block)
    callback_action(:create, (block_given? ? block : callback_or_path))
  end

  def update(callback_or_path=nil, &block)
    callback_action(:update, (block_given? ? block : callback_or_path))
  end

  def delete(callback_or_path=nil, &block)
    callback_action(:delete, (block_given? ? block : callback_or_path))
  end

  private

  def init_callbacks
    do_nothing = lambda {|base, relative|}
    @callbacks = Hash.new(do_nothing)
  end

  def callback_action(type, arg=nil)
    if arg.is_a?(Proc)
      set_callback(type, arg)
    elsif arg.nil?
      get_callback(type)
    else
      run_callback(type, arg)
    end
  end

  def set_callback(type, arg)
    raise ArgumentError, "Proc expected" unless arg.is_a?(Proc)
    @callbacks[type] = arg
  end

  def get_callback(type)
    @callbacks[type]
  end

  def run_callback(type, arg)
    base, relative = split_path(arg)

    begin
      @callbacks[type].call(base, relative)
    rescue Exception => e
      raise FSSM::CallbackError, "#{type} - #{base.join(relative)}: #{e.message}", e.backtrace
    end
  end

  def split_path(path)
    path = FSSM::Pathname.for(path)
    [@path, (path.relative? ? path : path.relative_path_from(@path))]
  end

  def set_path(path)
    path = FSSM::Pathname.for(path)
    raise FSSM::FileNotFoundError, "No such file or directory - #{path}" unless path.exist?
    @path = path.expand_path
  end

  def set_glob(glob)
    @glob = glob.is_a?(Array) ? glob : [glob]
  end
end
