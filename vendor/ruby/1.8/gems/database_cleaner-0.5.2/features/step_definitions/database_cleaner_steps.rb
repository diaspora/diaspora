Given /^I am using (ActiveRecord|DataMapper|MongoMapper|Mongoid|CouchPotato)$/ do |orm|
  @orm = orm
end

Given /^the (.+) cleaning strategy$/ do |strategy|
  @strategy = strategy
end

When "I run my scenarios that rely on a clean database" do
  full_dir ||= File.expand_path(File.dirname(__FILE__) + "/../../examples/")
  Dir.chdir(full_dir) do
    ENV['ORM'] = @orm.downcase
    ENV['STRATEGY'] = @strategy
    @out = `#{"jruby -S " if defined?(JRUBY_VERSION)}cucumber features`
    @status = $?.exitstatus
  end
end

Then "I should see all green" do
  unless @status == 0
    raise "Expected to see all green but we saw FAIL! Output:\n#{@out}"
  end
end


