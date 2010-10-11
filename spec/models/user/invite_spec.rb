#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let!(:invited_user) { create_user_with_invitation("abc")}

  context "the acceptance of an invitation" do
    it "should create the person with the passed in params" do
      Person.count.should be 0
      u = invited_user.accept_invitation!(:invitation_token => "abc",
                              :username => "user",
                              :password => "secret",
                              :password_confirmation => "secret",
                              :person => {:profile => {:first_name => "Bob",
                                :last_name  => "Smith"}} )
      Person.count.should be 1
      u.person.profile.first_name.should == "Bob"
    end
  end
  

end

def create_user_with_invitation(invitation_token, attributes={})
  user = User.new({:password => nil, :password_confirmation => nil}.update(attributes))
  #puts user.inspect
  #user.skip_confirmation!
  user.invitation_token = invitation_token
  user.invitation_sent_at = Time.now.utc
  user.save(:validate => false)
  user
end
