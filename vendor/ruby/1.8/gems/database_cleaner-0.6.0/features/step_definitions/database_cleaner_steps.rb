
Given /^I am using (ActiveRecord|DataMapper|MongoMapper|Mongoid|CouchPotato)$/ do |orm|
  @feature_runner = FeatureRunner.new
  @feature_runner.orm = orm
end

Given /^I am using (ActiveRecord|DataMapper|MongoMapper|CouchPotato|Mongoid) and (ActiveRecord|DataMapper|MongoMapper|CouchPotato|Mongoid)$/ do |orm1,orm2|
  @feature_runner = FeatureRunner.new
  @feature_runner.orm         = orm1
  @feature_runner.another_orm = orm2
end

Given /^the (.+) cleaning strategy$/ do |strategy|
  @feature_runner.strategy = strategy
end

When "I run my scenarios that rely on a clean database" do
  @feature_runner.go 'example'
end

When "I run my scenarios that rely on clean databases" do
  @feature_runner.multiple_databases = true
  @feature_runner.go 'example_multiple_db'
end

When "I run my scenarios that rely on clean databases using multiple orms" do
  @feature_runner.go 'example_multiple_orm'
end

Then "I should see all green" do
  fail "Feature failed with :#{@feature_runner.output}" unless @feature_runner.exit_status == 0
end
