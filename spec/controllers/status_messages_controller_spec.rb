#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController do
  before do
    @aspect1 = alice.aspects.first
    @aspect2 = bob.aspects.first

    request.env["HTTP_REFERER"] = ""
    sign_in :user, alice
    @controller.stub!(:current_user).and_return(alice)
    alice.reload
  end

  describe '#bookmarklet' do
    it 'succeeds' do
      get :bookmarklet
      response.should be_success
    end
  end

  describe '#new' do
    it 'succeeds' do
      get :new,
        :person_id => bob.person.id
      response.should be_success
    end

    it 'generates a jasmine fixture', :fixture => true do
      contact = alice.contact_for(bob.person)
      aspect = alice.aspects.create(:name => 'people')
      contact.aspects << aspect
      contact.save
      get :new, :person_id => bob.person.id, :layout => true
      save_fixture(html_for("body"), "status_message_new")
    end
  end

  describe '#create' do
    let(:status_message_hash) {
      { :status_message => {
        :public  => "true",
        :text => "facebook, is that you?",
        },
      :aspect_ids => [@aspect1.id.to_s] }
    }

    context 'js requests' do
      it 'responds' do
        post :create, status_message_hash.merge(:format => 'js')
        response.status.should == 201
      end

      it 'responds with json' do
        post :create, status_message_hash.merge(:format => 'js')
        json = JSON.parse(response.body)
        json['post_id'].should_not be_nil
        json['html'].should_not be_nil
      end

      it 'saves the html as a fixture', :fixture => true do
        post :create, status_message_hash.merge(:format => 'js')
        json = JSON.parse(response.body)
        save_fixture(json['html'], "created_status_message")
      end

      it 'escapes XSS' do
        xss = "<script> alert('hi browser') </script>"
        post :create, status_message_hash.merge(:format => 'js', :text => xss)
        json = JSON.parse(response.body)
        json['html'].should_not =~ /<script>/
      end
    end

    it 'takes public in aspect ids' do
      post :create, status_message_hash.merge(:aspect_ids => ['public'])
      response.status.should == 302
    end

    it 'takes all_aspects in aspect ids' do
      post :create, status_message_hash.merge(:aspect_ids => ['all_aspects'])
      response.status.should == 302
    end

    it "dispatches the post to the specified services" do
      s1 = Services::Facebook.new
      alice.services << s1
      alice.services << Services::Twitter.new
      status_message_hash[:services] = ['facebook']
      alice.should_receive(:dispatch_post).with(anything(), hash_including(:services => [s1]))
      post :create, status_message_hash
    end

    it "doesn't overwrite author_id" do
      status_message_hash[:status_message][:author_id] = bob.person.id
      post :create, status_message_hash
      new_message = StatusMessage.find_by_text(status_message_hash[:status_message][:text])
      new_message.author_id.should == alice.person.id
    end

    it "doesn't overwrite id" do
      old_status_message = alice.post(:status_message, :text => "hello", :to => @aspect1.id)
      status_message_hash[:status_message][:id] = old_status_message.id
      post :create, status_message_hash
      old_status_message.reload.text.should == 'hello'
    end

    it 'calls dispatch post once subscribers is set' do
      alice.should_receive(:dispatch_post){|post, opts|
        post.subscribers(alice).should == [bob.person]
      }
      post :create, status_message_hash
    end

    it 'respsects provider_display_name' do
      status_message_hash.merge!(:aspect_ids => ['public'])
      status_message_hash[:status_message].merge!(:provider_display_name => "mobile")
      post :create, status_message_hash
      StatusMessage.first.provider_display_name.should == 'mobile'
    end

# disabled to fix federation
#    it 'sends the errors in the body on js' do
#      post :create, status_message_hash.merge!(:format => 'js', :status_message => {:text => ''})
#      response.body.should include('Status message requires a message or at least one photo')
#    end

    context 'with photos' do
      before do
        @photo1 = alice.build_post(:photo, :pending => true, :user_file=> File.open(photo_fixture_name), :to => @aspect1.id)
        @photo2 = alice.build_post(:photo, :pending => true, :user_file=> File.open(photo_fixture_name), :to => @aspect1.id)

        @photo1.save!
        @photo2.save!

        @hash = status_message_hash
        @hash[:photos] = [@photo1.id.to_s, @photo2.id.to_s]
      end
      it "will post a photo without text" do
        @hash.delete :text
        post :create, @hash
        response.should be_redirect
      end
      it "attaches all referenced photos" do
        post :create, @hash
        assigns[:status_message].photos.map(&:id).should =~ [@photo1, @photo2].map(&:id)
      end
      it "sets the pending bit of referenced photos" do
        post :create, @hash
        @photo1.reload.pending.should be_false
        @photo2.reload.pending.should be_false
      end
    end
  end
end
