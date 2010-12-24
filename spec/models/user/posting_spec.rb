#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do

  let!(:user) { Factory.create(:user) }
  let!(:user2) { Factory.create(:user) }

  let!(:aspect) { user.aspects.create(:name => 'heroes') }
  let!(:aspect1) { user.aspects.create(:name => 'other') }
  let!(:aspect2) { user2.aspects.create(:name => 'losers') }

  let!(:service1) { s = Factory(:service, :provider => 'twitter'); user.services << s; s }
  let!(:service2) { s = Factory(:service, :provider => 'facebook'); user.services << s; s }

  describe '#add_to_streams' do
    before do
      @params = {:message => "hey", :to => [aspect.id, aspect1.id]}
      @post = user.build_post(:status_message, @params)
      @post.save
      @aspect_ids = @params[:to]
    end

    it 'saves post into visible post ids' do
      proc {
        user.add_to_streams(@post, @aspect_ids)
      }.should change{user.raw_visible_posts.all.length}.by(1)
      user.reload.raw_visible_posts.should include @post
    end

    it 'saves post into each aspect in aspect_ids' do
      user.add_to_streams(@post, @aspect_ids)
      aspect.reload.post_ids.should include @post.id
      aspect1.reload.post_ids.should include @post.id
    end

    it 'sockets the post to the poster' do
      @post.should_receive(:socket_to_uid).with(user.id, anything)
      user.add_to_streams(@post, @aspect_ids)
    end
  end

  describe '#aspects_from_ids' do
    it 'returns a list of all valid aspects a user can post to' do
      aspect_ids = Aspect.all.map(&:id)
      user.aspects_from_ids(aspect_ids).map{|a| a}.should ==
        user.aspects.map{|a| a} #Rspec matchers ftw
    end
    it "lets you post to your own aspects" do
      user.aspects_from_ids([aspect.id]).should == [aspect]
      user.aspects_from_ids([aspect1.id]).should == [aspect1]
    end
    it 'removes aspects that are not yours' do
      user.aspects_from_ids(aspect2.id).should == []
    end
  end

  describe '#build_post' do
    it 'sets status_message#message' do
      post = user.build_post(:status_message, :message => "hey", :to => aspect.id)
      post.message.should == "hey"
    end
    it 'does not save a status_message' do
      post = user.build_post(:status_message, :message => "hey", :to => aspect.id)
      post.persisted?.should be_false
    end

    it 'does not save a photo' do
      post = user.build_post(:photo, :user_file => uploaded_photo, :to => aspect.id)
      post.persisted?.should be_false
    end

  end


  describe '#post_to_services' do
    it 'only iterates through services if the post is public' do
      user.should_receive(:services).and_return([])
      post = user.build_post(:status_message, :message => "foo", :public => true, :to => user.aspects.first.id)
      user.post_to_services(post, "dfds")
    end
  end

  describe '#dispatch_post' do
    let(:status) {user.build_post(:status_message, @status_opts)}

    before do
      @message = "hello, world!"
      @status_opts = {:to => "all", :message => @message}
    end

    it "posts to a pubsub hub if enabled" do
      EventMachine::PubSubHubbub.should_receive(:new).and_return(FakeHttpRequest.new(:success))

      destination = "http://identi.ca/hub/"
      feed_location = "http://google.com/"

      EventMachine.run {
        user.post_to_hub(feed_location)
        EventMachine.stop
      }
    end

    it "calls post_to_services if status is public" do
      Resque.should_receive(:enqueue).with(Jobs::PostToServices, anything, anything, anything)
       status.public = true
      user.dispatch_post(status, :to => "all")
    end

    it 'pushes to aspects' do
      user.should_receive(:push_to_aspects)
      user.dispatch_post(status, :to => "all")
    end
  end

  describe '#update_post' do
    it 'should update fields' do
      photo = user.post(:photo, :user_file => uploaded_photo, :caption => "Old caption", :to => aspect.id)
      update_hash = {:caption => "New caption"}
      user.update_post(photo, update_hash)

      photo.caption.should match(/New/)
    end
  end

  context 'dispatching' do
    let!(:user3) { Factory.create(:user) }
    let!(:user4) { Factory.create(:user) }

    let!(:aspect3) { user3.aspects.create(:name => 'heroes') }
    let!(:aspect4) { user4.aspects.create(:name => 'heroes') }

    let!(:post) { user.build_post :status_message, :message => "hey" }
    let!(:request) { Request.diaspora_initialize(:from => user3.person, :to => user4.person) }

    before do
      connect_users(user, aspect, user2, aspect2)
      connect_users(user, aspect, user3, aspect3)
      connect_users(user, aspect1, user4, aspect4)
      contact = user.contact_for(user2.person)
      user.add_contact_to_aspect(contact, aspect1)
      user.reload
    end

    describe '#push_to_aspects' do
      it 'should push a post to a aspect' do
        user.should_receive(:push_to_person).twice
        user.push_to_aspects(post, [aspect])
      end

      it 'should push a post to contacts in all aspects' do
        user.should_receive(:push_to_person).exactly(3).times
        user.push_to_aspects(post, user.aspects)
      end
    end

    describe '#push_to_people' do
      it 'should push to people' do
        user.should_receive(:push_to_person).twice
        user.push_to_people(post, [user2.person, user3.person])
      end

      it 'does not use the queue for local transfer' do
        MessageHandler.should_receive(:add_post_request).once

        remote_person = user4.person
        remote_person.owner_id = nil
        remote_person.save
        remote_person.reload

        user.push_to_people(post, [user2.person, user3.person, remote_person])
      end
    end

    describe '#push_to_person' do
      before do
        @salmon = user.salmon(post)
        @xml = post.to_diaspora_xml
      end
      it 'enqueues receive for requests and retractions for local contacts' do
        xml = request.to_diaspora_xml
        Resque.should_receive(:enqueue).with(Jobs::Receive, user2.id, xml, user.person.id)
        user.push_to_person(@salmon, request, user2.person)
      end
      it 'enqueues receive for requests and retractions for local contacts' do
        Resque.should_receive(:enqueue).with(Jobs::ReceiveLocal, user2.id, user.person.id, post.class.to_s, post.id)
        user.push_to_person(@salmon, post, user2.person)
      end
      it 'calls the MessageHandler for remote contacts' do
        person = Factory.create(:person)
        MessageHandler.should_receive(:add_post_request).once
        user.push_to_person(@salmon, post, person)
      end
    end
  end
end
