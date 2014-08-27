#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Postzord::Dispatcher do
  before do
    @sm = FactoryGirl.create(:status_message, :public => true, :author => alice.person)
    @subscribers = []
    5.times{@subscribers << FactoryGirl.create(:person)}
    allow(@sm).to receive(:subscribers).and_return(@subscribers)
    @xml = @sm.to_diaspora_xml
  end

  describe '.initialize' do
    it 'sets @sender, @object, @xml' do
      zord = Postzord::Dispatcher.build(alice, @sm)
      expect(zord.sender).to eq(alice)
      expect(zord.object).to eq(@sm)
      expect(zord.xml).to eq(@sm.to_diaspora_xml)
    end

    context 'setting @subscribers' do
      it 'sets @subscribers from object' do
        expect(@sm).to receive(:subscribers).and_return(@subscribers)
        zord = Postzord::Dispatcher.build(alice, @sm)
        expect(zord.subscribers).to eq(@subscribers)
      end

      it 'accepts additional subscribers from opts' do
        new_person = FactoryGirl.create(:person)

        expect(@sm).to receive(:subscribers).and_return(@subscribers)
        zord = Postzord::Dispatcher.build(alice, @sm, :additional_subscribers => new_person)
        expect(zord.subscribers).to eq(@subscribers | [new_person])
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
        expect(@subscribers).to receive(:partition).and_return([@remote_people, @local_people])
        @zord.post
      end

      it 'calls #deliver_to_local with local people' do
        expect(@zord).to receive(:deliver_to_local).with(@local_people)
        @zord.post
      end

      it 'calls #deliver_to_remote with remote people' do
        expect(@zord).to receive(:deliver_to_remote).with(@remote_people)
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
              expect(@mailman).to receive(:deliver_to_local).with([@local_luke.person])
              @mailman.post
            end

            it 'calls deliver_to_remote with nobody' do
              expect(@mailman).to receive(:deliver_to_remote).with([])
              @mailman.post
            end

            it 'does not call notify_users' do
              expect(@mailman).not_to receive(:notify_users)
              @mailman.post
            end
          end
          context "local luke's mailman" do
            before do
              @mailman = Postzord::Dispatcher.build(@local_luke, @comment)
            end

            it 'does not call deliver_to_local' do
              expect(@mailman).not_to receive(:deliver_to_local)
              @mailman.post
            end

            it 'calls deliver_to_remote with remote raphael' do
              expect(@mailman).to receive(:deliver_to_remote).with([@remote_raphael])
              @mailman.post
            end

            it 'calls notify_users' do
              expect(@mailman).to receive(:notify_users).with([@local_leia])
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
            expect(@mailman).not_to receive(:deliver_to_local)
            @mailman.post
          end

          it 'calls deliver_to_remote with remote_raphael' do
            expect(@mailman).to receive(:deliver_to_remote).with([@remote_raphael])
            @mailman.post
          end

          it 'calls notify_users' do
            expect(@mailman).to receive(:notify_users).with([@local_leia])
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
            expect(@mailman).not_to receive(:deliver_to_local)
            @mailman.post
          end

          it 'calls deliver_to_remote with remote_raphael' do
            expect(@mailman).to receive(:deliver_to_remote).with([@remote_raphael])
            @mailman.post
          end

          it 'calls notify_users' do
            expect(@mailman).to receive(:notify_users).with([@local_leia])
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
          expect(@mailman).to receive(:deliver_to_remote).with([@remote_raphael])
          @mailman.post
        end

        it 'calls deliver_to_local with nobody' do
          expect(@mailman).to receive(:deliver_to_local).with([])
          @mailman.post
        end

        it 'does not call notify_users' do
          expect(@mailman).not_to receive(:notify_users)
          @mailman.post
        end
      end
    end

    describe '#deliver_to_remote' do
      before do
        @remote_people = []
        @remote_people << alice.person
        @mailman = Postzord::Dispatcher.build(alice, @sm)
        @hydra = double()
        allow(Typhoeus::Hydra).to receive(:new).and_return(@hydra)
      end

      it 'should queue an HttpMultiJob for the remote people' do
        allow_any_instance_of(Postzord::Dispatcher::Public).to receive(:deliver_to_remote).and_call_original
        expect(Workers::HttpMulti).to receive(:perform_async).with(alice.id, anything, @remote_people.map{|p| p.id}, anything).once
        @mailman.send(:deliver_to_remote, @remote_people)

        allow(Postzord::Dispatcher::Public).to receive(:deliver_to_remote)
      end
    end

    describe '#deliver_to_local' do
      before do
        @mailman = Postzord::Dispatcher.build(alice, @sm)
      end

      it 'queues a batch receive' do
        local_people = []
        local_people << alice.person
        expect(Workers::ReceiveLocalBatch).to receive(:perform_async).with(@sm.class.to_s, @sm.id, [alice.id]).once
        @mailman.send(:deliver_to_local, local_people)
      end

      it 'returns if people are empty' do
        expect(Workers::ReceiveLocalBatch).not_to receive(:perform_async)
        @mailman.send(:deliver_to_local, [])
      end

      it 'returns if the object is a profile' do
        @mailman.instance_variable_set(:@object, Profile.new)
        expect(Workers::ReceiveLocalBatch).not_to receive(:perform_async)
        @mailman.send(:deliver_to_local, [1])
      end
    end

    describe '#object_should_be_processed_as_public?' do
      it 'returns true with a comment on a public post' do
        f = FactoryGirl.create(:comment, :post => FactoryGirl.build(:status_message, :public => true))
        expect(Postzord::Dispatcher.object_should_be_processed_as_public?(f)).to be true
      end

      it 'returns false with a comment on a private post' do
        f = FactoryGirl.create(:comment, :post => FactoryGirl.build(:status_message, :public => false))
        expect(Postzord::Dispatcher.object_should_be_processed_as_public?(f)).to be false
      end

      it 'returns true with a like on a comment on a public post' do
        f = FactoryGirl.create(:like, :target => FactoryGirl.build(:comment, :post => FactoryGirl.build(:status_message, :public => true)))
        expect(Postzord::Dispatcher.object_should_be_processed_as_public?(f)).to be true
      end

      it 'returns false with a like on a comment on a private post' do
        f = FactoryGirl.create(:like, :target => FactoryGirl.build(:comment, :post => FactoryGirl.build(:status_message, :public => false)))
        expect(Postzord::Dispatcher.object_should_be_processed_as_public?(f)).to be false
      end

      it 'returns false for a relayable_retraction' do
        f = RelayableRetraction.new
        f.target = FactoryGirl.create(:status_message, :public => true)
        expect(Postzord::Dispatcher.object_should_be_processed_as_public?(f)).to be false
      end
    end


    describe '#deliver_to_services' do
      before do
        alice.aspects.create(:name => "whatever")
        @service = Services::Facebook.new(:access_token => "yeah")
        alice.services << @service
      end

      it 'queues a job to notify the hub' do
        allow(Workers::PostToService).to receive(:perform_async).with(anything, anything, anything)
        expect(Workers::PublishToHub).to receive(:perform_async).with(alice.public_url)
        @zord.send(:deliver_to_services, nil, [])
      end

      it 'does not push to hub for non-public posts' do
       @sm     = FactoryGirl.create(:status_message)
       mailman = Postzord::Dispatcher.build(alice, @sm, :url => "http://joindiaspora.com/p/123")

       expect(mailman).not_to receive(:deliver_to_hub)
       mailman.post
      end

      it 'only pushes to specified services' do
       @s1 = FactoryGirl.create(:service, :user_id => alice.id)
       alice.services << @s1
       @s2 = FactoryGirl.create(:service, :user_id => alice.id)
       alice.services << @s2
       mailman = Postzord::Dispatcher.build(alice, FactoryGirl.create(:status_message), :url => "http://joindiaspora.com/p/123", :services => [@s1])

       allow(Workers::PublishToHub).to receive(:perform_async).with(anything)
       allow(Workers::HttpMulti).to receive(:perform_async).with(anything, anything, anything)
       expect(Workers::PostToService).to receive(:perform_async).with(@s1.id, anything, anything)
       mailman.post
      end

      it 'does not push to services if none are specified' do
       mailman = Postzord::Dispatcher.build(alice, FactoryGirl.create(:status_message), :url => "http://joindiaspora.com/p/123")

       allow(Workers::PublishToHub).to receive(:perform_async).with(anything)
       expect(Workers::PostToService).not_to receive(:perform_async).with(anything, anything, anything)
       mailman.post
      end

      it 'queues a job to delete if given retraction' do
        retraction = SignedRetraction.build(alice, FactoryGirl.create(:status_message))
        mailman = Postzord::Dispatcher.build(alice, retraction,  :url => "http://joindiaspora.com/p/123", :services => [@service])

        expect(Workers::DeletePostFromService).to receive(:perform_async).with(anything, anything)
        mailman.post
      end

    end

    describe '#and_notify_local_users' do
      it 'calls notifiy_users' do
        expect(@zord).to receive(:notify_users).with([bob])
        @zord.send(:notify_local_users, [bob.person])
      end
    end

    describe '#notify_users' do
      it 'enqueues a NotifyLocalUsers job' do
        expect(Workers::NotifyLocalUsers).to receive(:perform_async).with([bob.id], @zord.object.class.to_s, @zord.object.id, @zord.object.author.id)
        @zord.send(:notify_users, [bob])
      end
    end
  end
end

