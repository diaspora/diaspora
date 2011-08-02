module FSSM::State
  class Directory
    attr_reader :path

    def initialize(path)
      @path = path
      @cache = FSSM::Tree::Cache.new
    end

    def refresh(base=nil, skip_callbacks=false)
      previous, current = recache(base || @path.to_pathname)

      unless skip_callbacks
        deleted(previous, current)
        created(previous, current)
        modified(previous, current)
      end
    end

    private

    def created(previous, current)
      (current.keys - previous.keys).each {|created| @path.create(created)}
    end

    def deleted(previous, current)
      (previous.keys - current.keys).each {|deleted| @path.delete(deleted)}
    end

    def modified(previous, current)
      (current.keys & previous.keys).each do |file|
        @path.update(file) if (current[file] <=> previous[file]) != 0
      end
    end

    def recache(base)
      base = FSSM::Pathname.for(base)
      previous = @cache.files
      snapshot(base)
      current = @cache.files
      [previous, current]
    end

    def snapshot(base)
      base = FSSM::Pathname.for(base)
      @cache.unset(base)
      @path.glob.each {|glob| add_glob(base, glob)}
    end

    def add_glob(base, glob)
      FSSM::Pathname.glob(base.join(glob).to_s).each do |fn|
        @cache.set(fn)
      end
    end

  end
end
