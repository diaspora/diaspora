class FSSM::Monitor
  def initialize(options={})
    @options = options
    @backend = FSSM::Backends::Default.new
  end

  def path(*args, &block)
    path = FSSM::Path.new(*args)
    FSSM::Support.use_block(path, block)

    @backend.add_handler(FSSM::State::Directory.new(path))
    path
  end

  def file(*args, &block)
    path = FSSM::Path.new(*args)
    FSSM::Support.use_block(path, block)

    @backend.add_handler(FSSM::State::File.new(path))
    path
  end

  def run
    @backend.run
  end
end
