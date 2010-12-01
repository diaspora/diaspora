require 'test/test_helper'
require 'rails/generators'
require 'generators/devise_invitable/devise_invitable_generator'

class GeneratorsTest < ActiveSupport::TestCase
  RAILS_APP_PATH = File.expand_path("../rails_app", __FILE__)
  
  test "rails g should include the 3 generators" do
    @output = `cd #{RAILS_APP_PATH} && rails g`
    assert @output.match(%r|DeviseInvitable:\n  devise_invitable\n  devise_invitable:install\n  devise_invitable:views|)
  end

  test "rails g devise_invitable:install" do
    @output = `cd #{RAILS_APP_PATH} && rails g devise_invitable:install -p`
    assert @output.match(%r|inject.+  config/initializers/devise\.rb\n|)
    assert @output.match(%r|create.+  config/locales/devise_invitable\.en\.yml\n|)
  end
  
  test "rails g devise_invitable:views not scoped" do
    @output = `cd #{RAILS_APP_PATH} && rails g devise_invitable:views -p`
    assert @output.match(%r|create.+  app/views/devise\n|)
    assert @output.match(%r|create.+  app/views/devise/invitations/edit\.html\.erb\n|)
    assert @output.match(%r|create.+  app/views/devise/invitations/new\.html\.erb\n|)
    assert @output.match(%r|create.+  app/views/devise/mailer/invitation\.html\.erb\n|)
  end
    
  test "rails g devise_invitable:views scoped" do
    @output = `cd #{RAILS_APP_PATH} && rails g devise_invitable:views octopussies -p`
    assert @output.match(%r|create.+  app/views/octopussies\n|)
    assert @output.match(%r|create.+  app/views/octopussies/invitations/edit\.html\.erb\n|)
    assert @output.match(%r|create.+  app/views/octopussies/invitations/new\.html\.erb\n|)
    assert @output.match(%r|create.+  app/views/octopussies/mailer/invitation\.html\.erb\n|)
  end
    
  test "rails g devise_invitable Octopussy" do
    @output = `cd #{RAILS_APP_PATH} && rails g devise_invitable Octopussy -p`
    assert @output.match(%r|inject.+  app/models/octopussy\.rb\n|)
    assert @output.match(%r|invoke.+  #{DEVISE_ORM}\n|)
    if DEVISE_ORM == :active_record
      assert @output.match(%r|create.+  db/migrate/\d{14}_devise_invitable_add_to_octopussies\.rb\n|)
    elsif DEVISE_ORM == :mongoid
      assert !@output.match(%r|create.+  db/migrate/\d{14}_devise_invitable_add_to_octopussies\.rb\n|)
    end
  end
end
