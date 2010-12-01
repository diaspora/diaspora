RSpec::Matchers.define :map_specs do |specs|
  match do |autotest|
    @specs = specs
    @autotest = prepare(autotest)
    autotest.test_files_for(@file) == specs
  end

  chain :to do |file|
    @file = file
  end

  failure_message_for_should do
    "expected #{@autotest.class} to map #{@specs.inspect} to #{@file.inspect}\ngot #{@actual.inspect}"
  end

  def prepare(autotest)
    find_order = @specs.dup << @file
    autotest.instance_eval { @find_order = find_order }
    autotest
  end
end

RSpec::Matchers.define :have_interface_for do |method|
  match do |object|
    @method = method
    @object = object
    object.respond_to?(method) && actual_arity == @expected_arity
  end

  chain :with do |arity|
    @expected_arity = arity
  end

  chain(:argument) {}
  chain(:arguments) {}

  failure_message_for_should do
    "#{@object} should have method :#{@method} with #{@expected_arity} argument(s), but it had #{actual_arity}"
  end

  def actual_arity
    @object.method(@method).arity
  end
end
