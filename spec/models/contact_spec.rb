#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Contact do
  describe 'validations' do
    let(:contact){Contact.new}

    it 'requires a user' do
      contact.valid?
      contact.errors.full_messages.should include "User can't be blank"
    end

    it 'requires a person' do
      contact.valid?
      contact.errors.full_messages.should include "Person can't be blank"
    end

    it 'ensures user is not making a contact for himself' do
      user = make_user

      contact.person = user.person
      contact.user = user

      contact.valid?
      contact.errors.full_messages.should include "Cannot create self-contact"
    end

    it 'has many aspects' do
      contact.associations[:aspects].type.should == :many
    end

    it 'validates uniqueness' do
      user = make_user
      person = Factory(:person)

      contact2 = Contact.create(:user => user,
                                :person => person)

      contact2.should be_valid

      contact.user = user
      contact.person = person
      contact.should_not be_valid
    end
  end


  context 'requesting' do
    before do
      @contact = Contact.new
      @user = make_user
      @person = Factory(:person)

      @contact.user = @user
      @contact.person = @person
    end

    describe '#generate_request' do
      it 'makes a request' do
        @contact.stub(:user).and_return(@user)
        request = @contact.generate_request

        request.from.should == @user
        request.to.should == @person
      end
    end

    describe '#dispatch_request' do
      it 'pushes to people' do
        @contact.stub(:user).and_return(@user)
        m = mock()
        m.should_receive(:post)
        Postzord::Dispatch.should_receive(:new).and_return(m)
        @contact.dispatch_request
      end
      it 'persists no request' do
        @contact.dispatch_request
        Request.from(@user).to(@person).first.should be_nil
      end
    end
  end
end
