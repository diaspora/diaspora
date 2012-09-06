#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Notifications::Reshared do
  before do
    @sm = FactoryGirl.build(:status_message, :author => alice.person, :public => true)
    @reshare1 = FactoryGirl.build(:reshare, :root => @sm)
    @reshare2 = FactoryGirl.build(:reshare, :root => @sm)
  end

  describe 'Notification.notify' do
    it 'calls concatenate_or_create with root post' do
      Notifications::Reshared.should_receive(:concatenate_or_create).with(alice, @reshare1.root, @reshare1.author, Notifications::Reshared)

      Notification.notify(alice, @reshare1, @reshare1.author)
    end
  end

  describe '#mail_job' do
    it "does not raise" do
      lambda{
        Notifications::Reshared.new.mail_job
      }.should_not raise_error
    end
  end

  describe '#concatenate_or_create' do
    it 'creates a new notification if one does not already exist' do
      Notifications::Reshared.should_receive(:make_notification).with(alice, @reshare1.root, @reshare1.author, Notifications::Reshared)
      Notifications::Reshared.concatenate_or_create(alice, @reshare1.root, @reshare1.author, Notifications::Reshared)
    end

    it "appends the actors to the aldeady existing notification" do
      note = Notifications::Reshared.make_notification(alice, @reshare1.root, @reshare1.author, Notifications::Reshared)
      lambda{
        Notifications::Reshared.concatenate_or_create(alice, @reshare2.root, @reshare2.author, Notifications::Reshared)
      }.should change(note.actors, :count).by(1)
    end
  end
end
