#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesController, :type => :controller do
  before do
    @aspect1 = alice.aspects.first

    request.env["HTTP_REFERER"] = ""
    sign_in :user, alice
    allow(@controller).to receive(:current_user).and_return(alice)
    alice.reload
  end

  describe '#bookmarklet' do
    it 'succeeds' do
      get :bookmarklet
      expect(response).to be_success
    end

    it 'contains a complete html document' do
      get :bookmarklet

      doc = Nokogiri(response.body)
      expect(doc.xpath('//head').count).to equal 1
      expect(doc.xpath('//body').count).to equal 1
    end

    it 'accepts get params' do
      get :bookmarklet, { url:   'https://www.youtube.com/watch?v=0Bmhjf0rKe8',
                          title: 'Surprised Kitty',
                          notes: 'cute kitty' }
      expect(response).to be_success
    end
  end

  describe '#new' do
    it 'succeeds' do
      get :new, :person_id => bob.person.id
      expect(response).to be_success
    end

    it 'should redirect on desktop version' do
      get :new
      expect(response).to redirect_to(stream_path)
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

    it 'creates with valid html' do
      post :create, status_message_hash
      expect(response.status).to eq(302)
      expect(response).to be_redirect
    end

    it 'creates with invalid html' do
      post :create, status_message_hash.merge(:status_message => { :text => "0123456789" * 7000 })
      expect(response.status).to eq(302)
      expect(response).to be_redirect
    end

    it 'creates with valid json' do
      post :create, status_message_hash.merge(:format => 'json')
      expect(response.status).to eq(201)
    end

    it 'creates with invalid json' do
      post :create, status_message_hash.merge(:status_message => { :text => "0123456789" * 7000 }, :format => 'json')
      expect(response.status).to eq(403)
    end

    it 'creates with valid mobile' do
      post :create, status_message_hash.merge(:format => 'mobile')
      expect(response.status).to eq(302)
      expect(response).to be_redirect
    end

    it 'creates with invalid mobile' do
      post :create, status_message_hash.merge(:status_message => { :text => "0123456789" * 7000 }, :format => 'mobile')
      expect(response.status).to eq(302)
      expect(response).to be_redirect
    end

    it 'removes getting started from new users' do
      expect(@controller).to receive(:remove_getting_started)
      post :create, status_message_hash
    end

    it 'takes public in aspect ids' do
      post :create, status_message_hash.merge(:aspect_ids => ['public'])
      expect(response.status).to eq(302)
    end

    it 'takes all_aspects in aspect ids' do
      post :create, status_message_hash.merge(:aspect_ids => ['all_aspects'])
      expect(response.status).to eq(302)
    end

    it "dispatches the post to the specified services" do
      s1 = Services::Facebook.new
      alice.services << s1
      alice.services << Services::Twitter.new
      status_message_hash[:services] = ['facebook']
      service_types = Service.titles(status_message_hash[:services])
      expect(alice).to receive(:dispatch_post).with(anything(), hash_including(:service_types => service_types))
      post :create, status_message_hash
    end

    it "works if services is a string" do
      s1 = Services::Facebook.new
      alice.services << s1
      status_message_hash[:services] = "facebook"
      expect(alice).to receive(:dispatch_post).with(anything(), hash_including(:service_types => ["Services::Facebook"]))
      post :create, status_message_hash
    end

    it "doesn't overwrite author_id" do
      status_message_hash[:status_message][:author_id] = bob.person.id
      post :create, status_message_hash
      new_message = StatusMessage.find_by_text(status_message_hash[:status_message][:text])
      expect(new_message.author_id).to eq(alice.person.id)
    end

    it "doesn't overwrite id" do
      old_status_message = alice.post(:status_message, :text => "hello", :to => @aspect1.id)
      status_message_hash[:status_message][:id] = old_status_message.id
      post :create, status_message_hash
      expect(old_status_message.reload.text).to eq('hello')
    end

    it 'calls dispatch post once subscribers is set' do
      expect(alice).to receive(:dispatch_post){|post, opts|
        expect(post.subscribers(alice)).to eq([bob.person])
      }
      post :create, status_message_hash
    end

    it 'respsects provider_display_name' do
      status_message_hash.merge!(:aspect_ids => ['public'])
      status_message_hash[:status_message].merge!(:provider_display_name => "mobile")
      post :create, status_message_hash
      expect(StatusMessage.first.provider_display_name).to eq('mobile')
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
        expect(response).to be_redirect
      end

      it "attaches all referenced photos" do
        post :create, @hash
        expect(assigns[:status_message].photos.map(&:id)).to match_array([@photo1, @photo2].map(&:id))
      end

      it "sets the pending bit of referenced photos" do
        inlined_jobs do
          post :create, @hash
        end

        expect(@photo1.reload.pending).to be false
        expect(@photo2.reload.pending).to be false
      end
    end
  end

  describe '#remove_getting_started' do
    it 'removes the getting started flag from new users' do
      alice.getting_started = true
      alice.save
      expect {
        @controller.send(:remove_getting_started)
      }.to change {
        alice.reload.getting_started
      }.from(true).to(false)
    end

    it 'does nothing for returning users' do
      expect {
        @controller.send(:remove_getting_started)
      }.to_not change {
        alice.reload.getting_started
      }
    end
  end
end
