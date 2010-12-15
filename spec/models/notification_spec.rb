#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'


describe Notification do 
  before do
    @sm = Factory(:status_message)
    @person = Factory(:person)
    @user = make_user
    @note = Notification.new(:object_id => @sm.id, :kind => @sm.class.name, :person => @person, :user => @user)
    puts @note.inspect
  end

  it 'contains a type' do
    @note.kind.should == StatusMessage.name
  end

  it 'contains a object_id' do
    @note.object_id.should == @sm.id
  end

  it 'contains a person_id' do
    @note.person.id == @person.id
  end
end

