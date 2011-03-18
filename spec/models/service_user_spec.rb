require 'spec_helper'

describe ServiceUser do

  describe '#finder' do
    before do
      @user = alice
      @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
      @service = Services::Facebook.new(:access_token => "yeah")
      @user.services << @service

      @user2 = Factory.create(:user_with_aspect)
      @user2_fb_id = '820651'
      @user2_fb_name = 'Maxwell Salzberg'
      @user2_fb_photo_url = 'http://cdn.fn.com/pic1.jpg'
      @user2_service = Services::Facebook.new(:uid => @user2_fb_id, :access_token => "yo")
      @user2.services << @user2_service
      @fb_list_hash =  <<JSON
      {
        "data": [
          {
            "name": "#{@user2_fb_name}",
            "id": "#{@user2_fb_id}",
            "picture": ""
          },
          {
            "name": "Person to Invite",
            "id": "abc123",
            "picture": "http://cdn.fn.com/pic1.jpg"
          }
        ]
      }
JSON
      @web_mock = mock()
      @web_mock.stub!(:body).and_return(@fb_list_hash)
      RestClient.stub!(:get).and_return(@web_mock)
    end

    context 'lifecycle callbacks' do
      before do
        @su = ServiceUser.create(:service_id => @service.id, :uid => @user2_fb_id, :name => @user2_fb_name,
                            :photo_url => @user2_fb_photo_url)
      end
      it 'contains a name' do
        @su.name.should == @user2_fb_name
      end
      it 'contains a photo url' do
        @su.photo_url.should == @user2_fb_photo_url
      end
      it 'contains a FB id' do
        @su.uid.should == @user2_fb_id
      end
      it 'contains a diaspora person object' do
        @su.person.should == @user2.person
      end
      it 'queries for the correct service type' do
        Services::Facebook.should_receive(:where).with(hash_including({:type => "Services::Facebook"})).and_return([])
        @su.send(:attach_local_models)
      end
      it 'does not include the person if the search is disabled' do
        p = @user2.person.profile
        p.searchable = false
        p.save
        @su.save
        @su.person.should be_nil
      end

      context "request" do
        before do
          @request = Request.diaspora_initialize(:from => @user2.person, :to => @user.person, :into => @user2.aspects.first)
          Postzord::Receiver.new(@user, :object => @request, :person => @user2.person).receive_object
          Request.count.should == 1
        end
        it 'contains a request object if one has been sent' do
          @su.save
          @su.request.should == @request
        end
      end

      it 'contains a contact object if connected' do
        connect_users(@user, @user.aspects.first, @user2, @user2.aspects.first)
        @su.save
        @su.contact.should == @user.reload.contact_for(@user2.person)
      end

      context 'already invited' do
        before do
          @user2.invitation_service = 'facebook'
          @user2.invitation_identifier = @user2_fb_id
          @user2.save!
        end
        it 'contains an invitation if invited' do
          @inv = Invitation.create(:sender => @user, :recipient => @user2, :aspect => @user.aspects.first)
          @su.save
          @su.invitation_id.should == @inv.id
        end
        it 'does not find the user with a wrong identifier' do
          @user2.invitation_identifier = 'dsaofhnadsoifnsdanf'
          @user2.save

          @inv = Invitation.create(:sender => @user, :recipient => @user2, :aspect => @user.aspects.first)
          @su.save
          @su.invitation_id.should be_nil
        end
      end
    end
  end
end
