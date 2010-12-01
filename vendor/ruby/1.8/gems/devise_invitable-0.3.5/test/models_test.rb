require 'test/test_helper'

class Invitable < User
  devise :database_authenticatable, :invitable, :invite_for => 5.days
end

class ActiveRecordTest < ActiveSupport::TestCase
  def include_module?(klass, mod)
    klass.devise_modules.include?(mod) &&
    klass.included_modules.include?(Devise::Models::const_get(mod.to_s.classify))
  end

  def assert_include_modules(klass, *modules)
    modules.each do |mod|
      assert include_module?(klass, mod), "#{klass} not include #{mod}"
    end
  end

  test 'add invitable module only' do
    assert_include_modules Invitable, :invitable
  end

  test 'set a default value for invite_for' do
    assert_equal 5.days, Invitable.invite_for
  end

  test 'invitable attributes' do
    assert_not_nil Invitable.columns_hash['invitation_token']
    assert_not_nil Invitable.columns_hash['invitation_sent_at']
  end
end
