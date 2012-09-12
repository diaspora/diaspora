#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require Rails.root.join('lib', 'postzord', 'dispatcher')

describe Postzord::Dispatcher do
  before do
    @sm = FactoryGirl.create(:status_message, :public => true, :author => alice.person)
    @subscribers = []
    5.times{@subscribers << FactoryGirl.create(:person)}
    @sm.stub(:subscribers).and_return(@subscribers)
    @xml = @sm.to_diaspora_xml
  end

  describe '.initialize' do
    it 'sets @sender, @object, @xml' do
      zord = Postzord::Dispatcher.build(alice, @sm)
      zord.sender.should == alice
      zord.object.should == @sm
      zord.xml.should == @sm.to_diaspora_xml
    end

    context 'setting @subscribers' do
      it 'sets @subscribers from object' do
        @sm.should_receive(:subscribers).and_return(@subscribers)
        zord = Postzord::Dispatcher.build(alice, @sm)
        zord.subscribers.should == @subscribers
      end

      it 'accepts additional subscribers from opts' do
        new_person = FactoryGirl.create(:person)

        @sm.should_receive(:subscribers).and_return(@subscribers)
        zord = Postzord::Dispatcher.build(alice, @sm, :additional_subscribers => new_person)
        zord.subscribers.should == @subscribers | [new_person]
      end
    end

    it 'raises and gives you a helpful message if the object can not federate' do
      expect {
        Postzord::Dispatcher.build(alice, [])
      }.to raise_error /Diaspora::Federated::Base/
    end
  end

  context 'instance methods' do
    before do
      @subscribers << bob.person
      @remote_people, @local_people = @subscribers.partition{ |person| person.owner_id.nil? }

      @zord = Postzord::Dispatcher.build(alice, @sm)
    end

    describe '#post' do
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
              @mailman = Postzord::Dispatcher.build(@local_leia, @comment)
            end

            it 'calls deliver_to_local with local_luke' do
              @mailman.should_receive(:deliver_to_local).with([@local_luke.person])
              @mailman.post
            end

            it 'calls deliver_to_remote with nobody' do
              @mailman.should_receive(:deliver_to_remote).with([])
              @mailman.post
            end

            it 'does not call notify_users' do
              @mailman.should_not_receive(:notify_users)
              @mailman.post
            end
          end
          context "local luke's mailman" do
            before do
              @mailman = Postzord::Dispatcher.build(@local_luke, @comment)
            end

            it 'does not call deliver_to_local' do
              @mailman.should_not_receive(:deliver_to_local)
              @mailman.post
            end

            it 'calls deliver_to_remote with remote raphael' do
              @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
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
            @comment = FactoryGirl.create(:comment, :author => @remote_raphael, :post => @post)
            @comment.save
            @mailman = Postzord::Dispatcher.build(@local_luke, @comment)
          end

          it 'does not call deliver_to_local' do
            @mailman.should_not_receive(:deliver_to_local)
            @mailman.post
          end

          it 'calls deliver_to_remote with remote_raphael' do
            @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
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
            @mailman = Postzord::Dispatcher.build(@local_luke, @comment)
          end

          it 'does not call deliver_to_local' do
            @mailman.should_not_receive(:deliver_to_local)
            @mailman.post
          end

          it 'calls deliver_to_remote with remote_raphael' do
            @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
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
          @post = FactoryGirl.create(:status_message, :author => @remote_raphael)
          @comment = @local_luke.build_comment :text => "yo", :post => @post
          @comment.save
          @mailman = Postzord::Dispatcher.build(@local_luke, @comment)
        end

        it 'calls deliver_to_remote with remote_raphael' do
          @mailman.should_receive(:deliver_to_remote).with([@remote_raphael])
          @mailman.post
        end

        it 'calls deliver_to_local with nobody' do
          @mailman.should_receive(:deliver_to_local).with([])
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
        @mailman = Postzord::Dispatcher.build(alice, @sm)
        @hydra = mock()
        Typhoeus::Hydra.stub!(:new).and_return(@hydra)
      end

      it 'should queue an HttpMultiJob for the remote people' do
        Postzord::Dispatcher::Public.any_instance.unstub(:deliver_to_remote)
        Resque.should_receive(:enqueue).with(Jobs::HttpMulti, alice.id, anything, @remote_people.map{|p| p.id}, anything).once
        @mailman.send(:deliver_to_remote, @remote_people)

        Postzord::Dispatcher::Public.stub(:deliver_to_remote)
      end
    end

    describe '#deliver_to_local' do
      before do
        @mailman = Postzord::Dispatcher.build(alice, @sm)
      end

      it 'queues a batch receive' do
        local_people = []
        local_people << alice.person
        Resque.should_receive(:enqueue).with(Jobs::ReceiveLocalBatch, @sm.class.to_s, @sm.id, [alice.id]).once
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

    describe '#object_should_be_processed_as_public?' do
      it 'returns true with a comment on a public post' do
        f = FactoryGirl.create(:comment, :post => FactoryGirl.build(:status_message, :public => true))
        Postzord::Dispatcher.object_should_be_processed_as_public?(f).should be_true
      end

      it 'returns false with a comment on a private post' do
        f = FactoryGirl.create(:comment, :post => FactoryGirl.build(:status_message, :public => false))
        Postzord::Dispatcher.object_should_be_processed_as_public?(f).should be_false
      end

      it 'returns true with a like on a comment on a public post' do
        f = FactoryGirl.create(:like, :target => FactoryGirl.build(:comment, :post => FactoryGirl.build(:status_message, :public => true)))
        Postzord::Dispatcher.object_should_be_processed_as_public?(f).should be_true
      end

      it 'returns false with a like on a comment on a private post' do
        f = FactoryGirl.create(:like, :target => FactoryGirl.build(:comment, :post => FactoryGirl.build(:status_message, :public => false)))
        Postzord::Dispatcher.object_should_be_processed_as_public?(f).should be_false
      end

      it 'returns false for a relayable_retraction' do
        f = RelayableRetraction.new
        f.target = FactoryGirl.create(:status_message, :public => true)
        Postzord::Dispatcher.object_should_be_processed_as_public?(f).should be_false
      end
    end


    describe '#deliver_to_services' do
      before do
        alice.aspects.create(:name => "whatever")
        @service = Services::Facebook.new(:access_token => "yeah")
        alice.services << @service
      end

      it 'queues a job to notify the hub' do
        Resque.stub!(:enqueue).with(Jobs::PostToService, anything, anything, anything)
        Resque.should_receive(:enqueue).with(Jobs::PublishToHub, alice.public_url)
        @zord.send(:deliver_to_services, nil, [])
      end

      it 'does not push to hub for non-public posts' do
       @sm     = FactoryGirl.create(:status_message)
       mailman = Postzord::Dispatcher.build(alice, @sm, :url => "http://joindiaspora.com/p/123")

       mailman.should_not_receive(:deliver_to_hub)
       mailman.post
      end

      it 'only pushes to specified services' do
       @s1 = FactoryGirl.create(:service, :user_id => alice.id)
       alice.services << @s1
       @s2 = FactoryGirl.create(:service, :user_id => alice.id)
       alice.services << @s2
       mailman = Postzord::Dispatcher.build(alice, FactoryGirl.create(:status_message), :url => "http://joindiaspora.com/p/123", :services => [@s1])

       Resque.stub!(:enqueue).with(Jobs::PublishToHub, anything)
       Resque.stub!(:enqueue).with(Jobs::HttpMulti, anything, anything, anything)
       Resque.should_receive(:enqueue).with(Jobs::PostToService, @s1.id, anything, anything)
       mailman.post
      end

      it 'does not push to services if none are specified' do
       mailman = Postzord::Dispatcher.build(alice, FactoryGirl.create(:status_message), :url => "http://joindiaspora.com/p/123")

       Resque.stub!(:enqueue).with(Jobs::PublishToHub, anything)
       Resque.should_not_receive(:enqueue).with(Jobs::PostToService, anything, anything, anything)
       mailman.post
      end
    end

    describe '#and_notify_local_users' do
      it 'calls notifiy_users' do
        @zord.should_receive(:notify_users).with([bob])
        @zord.send(:notify_local_users, [bob.person])
      end
    end

    describe '#notify_users' do
      it 'enqueues a NotifyLocalUsers job' do
        Resque.should_receive(:enqueue).with(Jobs::NotifyLocalUsers, [bob.id], @zord.object.class.to_s, @zord.object.id, @zord.object.author.id)
        @zord.send(:notify_users, [bob])
      end
    end
  end
end

