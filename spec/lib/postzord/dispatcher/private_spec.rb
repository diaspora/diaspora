#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/postzord/dispatcher/private')

describe Postzord::Dispatcher::Private do
  before do
    @sm = Factory(:status_message, :public => true, :author => alice.person)
    @subscribers = []
    5.times{@subscribers << Factory(:person)}
    @sm.stub(:subscribers).and_return(@subscribers)
    @xml = @sm.to_diaspora_xml
  end

  describe '.initialize' do
    it 'sets @sender, @object, @xml' do
      zord = Postzord::Dispatcher::Private.new(alice, @sm)
      zord.sender.should == alice
      zord.object.should == @sm
      zord.xml.should == @sm.to_diaspora_xml
    end

    context 'setting @subscribers' do 
      it 'sets @subscribers from object' do
        @sm.should_receive(:subscribers).and_return(@subscribers)
        zord = Postzord::Dispatcher::Private.new(alice, @sm)
        zord.subscribers.should == @subscribers
      end

      it 'accepts additional subscribers from opts' do
        new_person = Factory(:person)

        @sm.should_receive(:subscribers).and_return(@subscribers)
        zord = Postzord::Dispatcher::Private.new(alice, @sm, :additional_subscribers => new_person)
        zord.subscribers.should == @subscribers | [new_person]
      end
    end

    it 'raises and gives you a helpful message if the object can not federate' do
      pending "put this in the base class!"
      expect {
        Postzord::Dispatcher::Private.new(alice, [])
      }.should raise_error /Diaspora::Webhooks/
    end
  end

  context 'instance methods' do
    before do
      @subscribers << bob.person
      @remote_people, @local_people = @subscribers.partition{ |person| person.owner_id.nil? }

      @zord = Postzord::Dispatcher::Private.new(alice, @sm)
    end

    describe '#post' do
      before do
        @zord.stub!(:socket_and_notify_users)
      end
      it 'calls Array#partition on subscribers' do
        @zord.instance_variable_set(:@subscribers, @subscribers)
        @subscribers.should_receive(:partition).and_return([@remote_people, @local_people])
        @zord.post
      end

      it 'calls #deliver_to_local with local people' do
        @zord.should_receive(:deliver_to_local).with(@local_people)
        @zord.post
      end

      it 'calls #deliver_to_remote with remote people' do
        @zord.should_receive(:deliver_to_remote).with(@remote_people)
        @zord.post
      end
    end

    context "comments" do
      before do
        @local_luke, @local_leia, @remote_raphael = set_up_friends
      end

      context "local luke's post is commented on by" do
        before do
          @post = @local_luke.post(:status_message, :text => "hello", :to => @local_luke.aspects.first)
        end
        context "local leia" do
          before do
            @comment = @local_leia.build_comment :text => "yo", :post => @post
            @comment.save
          end
          context "local leia's mailman" do
            before do
              @mailman = Postzord::Dispatcher::Private.new(@local_leia, @comment)
            end
            it 'calls deliver_to_local with local_luke' do
              @mailman.should_receive(:deliver_to_local).with([@local_luke.person])
              @mailman.post
            end
            it 'calls deliver_to_remote with nobody' do
              @mailman.should_receive(:deliver_to_remote).with([])
              @mailman.post
            end
            it 'does not call socket_to_users' do
              @mailman.should_not_receive(:socket_to_users)
              @mailman.post
            end
            it 'does not call notify_users' do
              @mailman.should_not_receive(:notify_users)
              @mailman.post
            end
          end
          context "local luke's mailman" do
            before do
              @mailman = Postzord::Dispatcher::Private.new(@local_luke, @comment)
            end
            it 'does not call deliver_to_local' do
              @mailman.should_not_receive(:deliver_to_local)
              @mailman.post
            end
            it 'calls deliver_to_remote with remote raphael' do
              @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
              @mailman.post
            end
            it 'calls socket_to_users' do
              @mailman.should_receive(:socket_to_users).with([@local_leia, @local_luke])
              @mailman.post
            end
            it 'calls notify_users' do
              @mailman.should_receive(:notify_users).with([@local_leia])
              @mailman.post
            end
          end
        end

        context "remote raphael" do
          before do
            @comment = Factory.build(:comment, :author => @remote_raphael, :post => @post)
            @comment.save
            @mailman = Postzord::Dispatcher::Private.new(@local_luke, @comment)
          end

          it 'does not call deliver_to_local' do
            @mailman.should_not_receive(:deliver_to_local)
            @mailman.post
          end

          it 'calls deliver_to_remote with remote_raphael' do
            @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
            @mailman.post
          end

          it 'calls socket_to_users' do
            @mailman.should_receive(:socket_to_users).with([@local_leia])
            @mailman.post
          end

          it 'calls notify_users' do
            @mailman.should_receive(:notify_users).with([@local_leia])
            @mailman.post
          end
        end

        context "local luke" do
          before do
            @comment = @local_luke.build_comment :text => "yo", :post => @post
            @comment.save
            @mailman = Postzord::Dispatcher::Private.new(@local_luke, @comment)
          end

          it 'does not call deliver_to_local' do
            @mailman.should_not_receive(:deliver_to_local)
            @mailman.post
          end

          it 'calls deliver_to_remote with remote_raphael' do
            @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
            @mailman.post
          end

          it 'calls socket_to_users' do
            @mailman.should_receive(:socket_to_users).with([@local_leia, @local_luke])
            @mailman.post
          end

          it 'calls notify_users' do
            @mailman.should_receive(:notify_users).with([@local_leia])
            @mailman.post
          end
        end
      end

      context "remote raphael's post is commented on by local luke" do
        before do
          @post = Factory(:status_message, :author => @remote_raphael)
          @comment = @local_luke.build_comment :text => "yo", :post => @post
          @comment.save
          @mailman = Postzord::Dispatcher::Private.new(@local_luke, @comment)
        end

        it 'calls deliver_to_remote with remote_raphael' do
          @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
          @mailman.post
        end

        it 'calls deliver_to_local with nobody' do
          @mailman.should_receive(:deliver_to_local).with([])
          @mailman.post
        end

        it 'does not call socket_to_users' do
          @mailman.should_not_receive(:socket_to_users)
          @mailman.post
        end

        it 'does not call notify_users' do
          @mailman.should_not_receive(:notify_users)
          @mailman.post
        end
      end
    end

    describe '#deliver_to_remote' do
      before do
        @remote_people = []
        @remote_people << alice.person
        @mailman = Postzord::Dispatcher::Private.new(alice, @sm)
        @hydra = mock()
        Typhoeus::Hydra.stub!(:new).and_return(@hydra)
      end

      it 'should queue an HttpPost job for each remote person' do
        Resque.should_receive(:enqueue).with(Job::HttpMulti, alice.id, anything, @remote_people.map{|p| p.id}).once
        @mailman.send(:deliver_to_remote, @remote_people)
      end
    end

    describe '#deliver_to_local' do
      before do
        @mailman = Postzord::Dispatcher::Private.new(alice, @sm)
      end

      it 'queues a batch receive' do
        local_people = []
        local_people << alice.person
        Resque.should_receive(:enqueue).with(Job::ReceiveLocalBatch, @sm.id, [alice.id]).once
        @mailman.send(:deliver_to_local, local_people)
      end

      it 'returns if people are empty' do
        Resque.should_not_receive(:enqueue)
        @mailman.send(:deliver_to_local, [])
      end

      it 'returns if the object is a profile' do
        @mailman.instance_variable_set(:@object, Profile.new)
        Resque.should_not_receive(:enqueue)
        @mailman.send(:deliver_to_local, [1])
      end
    end

    describe '#deliver_to_services' do
      before do
        alice.aspects.create(:name => "whatever")
        @service = Services::Facebook.new(:access_token => "yeah")
        alice.services << @service
      end

      it 'queues a job to notify the hub' do
        Resque.stub!(:enqueue).with(Job::PostToService, anything, anything, anything)
        Resque.should_receive(:enqueue).with(Job::PublishToHub, alice.public_url)
        @zord.send(:deliver_to_services, nil, [])
      end

      it 'does not push to hub for non-public posts' do
       @sm     = Factory(:status_message)
       mailman = Postzord::Dispatcher::Private.new(alice, @sm)

       mailman.should_not_receive(:deliver_to_hub)
       mailman.post(:url => "http://joindiaspora.com/p/123")
      end

      it 'only pushes to specified services' do
       @s1 = Factory.create(:service, :user_id => alice.id)
       alice.services << @s1
       @s2 = Factory.create(:service, :user_id => alice.id)
       alice.services << @s2
       mailman = Postzord::Dispatcher::Private.new(alice, Factory(:status_message))

       Resque.stub!(:enqueue).with(Job::PublishToHub, anything)
       Resque.stub!(:enqueue).with(Job::HttpMulti, anything, anything, anything)
       Resque.should_receive(:enqueue).with(Job::PostToService, @s1.id, anything, anything)
       mailman.post(:url => "http://joindiaspora.com/p/123", :services => [@s1])
      end

      it 'does not push to services if none are specified' do
       mailman = Postzord::Dispatcher::Private.new(alice, Factory(:status_message))

       Resque.stub!(:enqueue).with(Job::PublishToHub, anything)
       Resque.should_not_receive(:enqueue).with(Job::PostToService, anything, anything, anything)
       mailman.post(:url => "http://joindiaspora.com/p/123")
      end
    end

    describe '#socket_and_notify_users' do
      it 'should call object#socket_to_user for each local user' do
        sc = mock()
        SocketsController.should_receive(:new).and_return(sc)
        sc.should_receive(:outgoing).with(bob,
                                          @zord.instance_variable_get(:@object),
                                          :aspect_ids => bob.contact_for(alice.person).aspect_memberships.map{|a| postgres? ? a.aspect_id.to_s : a.aspect_id })
        @zord.send(:socket_and_notify_users, [bob])
      end

      it 'only tries to socket when the object responds to #socket_to_user' do
        f = Request.new
        f.stub!(:subscribers)
        f.stub!(:to_diaspora_xml)
        users = [bob]
        z = Postzord::Dispatcher::Private.new(alice, f)
        z.instance_variable_get(:@object).should_receive(:socket_to_user).once
        z.send(:socket_to_users, users)
      end

      it 'queues Job::NotifyLocalUsers jobs' do
        @zord.instance_variable_get(:@object).should_receive(:socket_to_user).and_return(false)
        Resque.should_receive(:enqueue).with(Job::NotifyLocalUsers, [bob.id], @sm.class.to_s, @sm.id, @sm.author.id)
        @zord.send(:socket_and_notify_users, [bob])
      end
    end
  end
end
