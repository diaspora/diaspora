module Factory
  def self.method_missing(name, *args, &block)
    if FactoryGirl.respond_to?(name)
      $stderr.puts "DEPRECATION WARNING: Change Factory.#{name} to FactoryGirl.#{name}"
      FactoryGirl.send(name, *args, &block)
    else
      super(name, *args, &block)
    end
  end

  def self.const_missing(name)
    if FactoryGirl.const_defined?(name)
      FactoryGirl.const_get(name)
    else
      super(name)
    end
  end
end
