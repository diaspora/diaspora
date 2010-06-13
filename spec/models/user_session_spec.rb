require 'spec_helper'

describe UserSession do
  before do
    UserSession.delete_all
    User.delete_all
  end

  it "should authenticate an existing user" do
    user = User.create(:name => "billy", :password => "bob")
    puts User.first.inspect
    UserSession.new.authenticates(user.name, user.password).should be true
  end

  it "should not authenticate a foreign user" do
    user = User.create(:name => "billy", :password => "bob")
    UserSession.new.authenticates("not billy", "not bob").should be nil
  end
end
