#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/postzord')
require File.join(Rails.root, 'lib/postzord/dispatch')

describe Postzord::Dispatch do
  before do
    @user = alice
    @sm = Factory(:status_message, :public => true)
    @subscribers = []
    5.times{@subscribers << Factory(:person)}
    @sm.stub!(:subscribers)
    @xml = @sm.to_diaspora_xml
  end

  describe '.initialize' do
    it 'takes an sender(User) and object (responds_to #subscibers) and sets then to @sender and @object' do
      zord = Postzord::Dispatch.new(@user, @sm)
      zord.instance_variable_get(:@sender).should == @user
      zord.instance_variable_get(:@object).should == @sm
    end

    it 'sets @subscribers from object' do
      @sm.should_receive(:subscribers).and_return(@subscribers)
      zord = Postzord::Dispatch.new(@user, @sm)
      zord.instance_variable_get(:@subscribers).should == @subscribers
    end

    it 'sets the @sender_person object' do
      zord = Postzord::Dispatch.new(@user, @sm)
      zord.instance_variable_get(:@sender_person).should == @user.person
    end

    it 'raises and gives you a helpful message if the object can not federate' do
      proc{ Postzord::Dispatch.new(@user, [])
      }.should raise_error /Diaspora::Webhooks/
    end
  end

  it 'creates a salmon base object' do
    zord = Postzord::Dispatch.new(@user, @sm)
    zord.salmon.should_not be nil
  end

  context 'instance methods' do
    before do
      @local_user = eve
      @subscribers << @local_user.person
      @remote_people, @local_people = @subscribers.partition{ |person| person.owner_id.nil? }
      @sm.stub!(:subscribers).and_return @subscribers
      @zord =  Postzord::Dispatch.new(@user, @sm)
    end

    describe '#post' do
      before do
        @zord.stub!(:socket_and_notify_users)
      end
      it 'calls Array#partition on subscribers' do
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

      context "comments" do
        before do
          @local_luke, @local_leia, @remote_raphael = set_up_friends
        end

        context "local luke's post is commented on by" do
          before do
            @post = @local_luke.post(:status_message, :message => "hello", :to => @local_luke.aspects.first)
          end
          context "local leia" do
            before do
              @comment = @local_leia.build_comment "yo", :on => @post
              @comment.save
            end
            context "local leia's mailman" do
              before do
                @mailman = Postzord::Dispatch.new(@local_leia, @comment)
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
                @mailman = Postzord::Dispatch.new(@local_luke, @comment)
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
              @comment = Factory.build(:comment, :person => @remote_raphael, :post => @post)
              @comment.save
              @mailman = Postzord::Dispatch.new(@local_luke, @comment)
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
              @comment = @local_luke.build_comment "yo", :on => @post
              @comment.save
              @mailman = Postzord::Dispatch.new(@local_luke, @comment)
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
            @post = Factory(:status_message, :person => @remote_raphael)
            @comment = @local_luke.build_comment "yo", :on => @post
            @comment.save
            @mailman = Postzord::Dispatch.new(@local_luke, @comment)
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
    end

    describe '#deliver_to_remote' do
      before do
        @remote_people = []
        @remote_people << @user.person
        @mailman = Postzord::Dispatch.new(@user, @sm)
        @hydra = mock()
        Typhoeus::Hydra.stub!(:new).and_return(@hydra)
      end

      it 'should queue an HttpPost job for each remote person' do
        Resque.should_receive(:enqueue).with(Job::HttpMulti, @user.id, anything, @remote_people.map{|p| p.id}).once
        @mailman.send(:deliver_to_remote, @remote_people)
      end

      it 'calls salmon_for each remote person' do
       salmon = @mailman.salmon
       Salmon::SalmonSlap.stub(:create).and_return(salmon)
       salmon.should_receive(:xml_for).with(@user.person).and_return('what')
       @hydra.stub!(:queue)
       @hydra.stub!(:run)
       fantasy_resque do
         @mailman.send(:deliver_to_remote, @remote_people)
       end
      end
    end

    describe '#deliver_to_local' do
      it 'sends each person an object' do
        local_people = []
        local_people << @user.person
        mailman = Postzord::Dispatch.new(@user, @sm)
        Resque.should_receive(:enqueue).with(Job::Receive, @user.id, @xml, anything).once
        mailman.send(:deliver_to_local, local_people)
      end
    end

    describe '#deliver_to_services' do
      before do
        @user.aspects.create(:name => "whatever")
        @service = Services::Facebook.new(:access_token => "yeah")
        @user.services << @service
      end

      it 'calls post for each of the users services' do
        Resque.stub!(:enqueue).with(Job::PublishToHub, anything)
        Resque.should_receive(:enqueue).with(Job::PostToService, @service.id, anything, anything).once
        @zord.instance_variable_get(:@sender).should_receive(:services).and_return([@service])
        @zord.send(:deliver_to_services, nil)
      end

      it 'queues a job to notify the hub' do
        Resque.stub!(:enqueue).with(Job::PostToService, anything, anything, anything)
        Resque.should_receive(:enqueue).with(Job::PublishToHub, @user.public_url)
        @zord.send(:deliver_to_services, nil)
      end

      it 'only pushes to services if the object is public' do
       mailman = Postzord::Dispatch.new(@user, Factory(:status_message))

       mailman.should_not_receive(:deliver_to_hub)
       mailman.instance_variable_get(:@sender).should_not_receive(:services)
      end
    end

    describe '#socket_and_notify_users' do
      it 'should call object#socket_to_user for each local user' do
        @zord.instance_variable_get(:@object).should_receive(:socket_to_user)
        @zord.send(:socket_and_notify_users, [@local_user])
      end

      it 'only tries to socket when the object responds to #socket_to_user' do
        f = Request.new
        f.stub!(:subscribers)
        f.stub!(:to_diaspora_xml)
        users = [@user]
        z = Postzord::Dispatch.new(@user, f)
        z.instance_variable_get(:@object).should_receive(:socket_to_user).once
        z.send(:socket_to_users, users)
      end

      it 'queues Job::NotifyLocalUsers jobs' do
        @zord.instance_variable_get(:@object).should_receive(:socket_to_user).and_return(false)
        Resque.should_receive(:enqueue).with(Job::NotifyLocalUsers, @local_user.id, @sm.class.to_s, @sm.id, @sm.person.id)
        @zord.send(:socket_and_notify_users, [@local_user])
      end
    end
  end
end
