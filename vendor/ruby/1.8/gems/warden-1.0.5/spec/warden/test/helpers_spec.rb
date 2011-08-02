# encoding: utf-8
require 'spec_helper'

describe Warden::Test::Helpers do
  include Warden::Test::Helpers

  before{ $captures = [] }
  after{ Warden.test_reset! }

  it "should log me in as a user" do
    user = "A User"
    login_as user
    app = lambda{|e|
      $captures << :run
      e['warden'].should be_authenticated
      e['warden'].user.should == "A User"
      valid_response
    }
    setup_rack(app).call(env_with_params)
    $captures.should == [:run]
  end

  it "should log me in as a user of a given scope" do
    user = {:some => "user"}
    login_as user, :scope => :foo_scope
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      w.should be_authenticated(:foo_scope)
      w.user(:foo_scope).should == {:some => "user"}
    }
    setup_rack(app).call(env_with_params)
    $captures.should == [:run]
  end

  it "should login multiple users with different scopes" do
    user      = "A user"
    foo_user  = "A foo user"
    login_as user
    login_as foo_user, :scope => :foo
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      w.user.should == "A user"
      w.user(:foo).should == "A foo user"
      w.should be_authenticated
      w.should be_authenticated(:foo)
    }
    setup_rack(app).call(env_with_params)
    $captures.should == [:run]
  end

  it "should log out all users" do
    user = "A user"
    foo  = "Foo"
    login_as user
    login_as foo, :scope => :foo
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      w.user.should == "A user"
      w.user(:foo).should == "Foo"
      w.logout
      w.user.should be_nil
      w.user(:foo).should be_nil
      w.should_not be_authenticated
      w.should_not be_authenticated(:foo)
    }
    setup_rack(app).call(env_with_params)
    $captures.should == [:run]
  end

  it "should logout a specific user" do
    user = "A User"
    foo  = "Foo"
    login_as user
    login_as foo, :scope => :foo
    app = lambda{|e|
      $captures << :run
      w = e['warden']
      w.logout :foo
      w.user.should == "A User"
      w.user(:foo).should be_nil
      w.should_not be_authenticated(:foo)
    }
    setup_rack(app).call(env_with_params)
    $captures.should == [:run]
  end

end
