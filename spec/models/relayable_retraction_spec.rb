#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join("spec", "shared_behaviors", "relayable")

describe RelayableRetraction do
  before do
    @local_luke, @local_leia, @remote_raphael = set_up_friends
    @remote_parent = FactoryGirl.build(:status_message, :author => @remote_raphael)
    @local_parent = @local_luke.post :status_message, :text => "hi", :to => @local_luke.aspects.first
  end

  context "when retracting a comment" do
    before do
      @comment= @local_luke.comment!(@local_parent, "yo")
      @retraction= @local_luke.retract(@comment)
    end

    describe "#parent" do
      it "delegates to to target" do
        @retraction.target.should_receive(:parent)
        @retraction.parent
      end
    end

    describe "#parent_author" do
      it "delegates to target" do
        @retraction.target.should_receive(:parent_author)
        @retraction.parent_author
      end
    end

    describe '#subscribers' do
      it 'delegates it to target' do
        arg = mock()
        @retraction.target.should_receive(:subscribers).with(arg)
        @retraction.subscribers(arg)
      end
    end
  end

  describe '#receive' do
    it 'discards a retraction with a nil target' do
      @comment= @local_luke.comment!(@local_parent, "yo")
      @retraction= @local_luke.retract(@comment)

      @retraction.instance_variable_set(:@target, nil)
      @retraction.target_guid = '135245'
      @retraction.should_not_receive(:perform)
      @retraction.receive(@local_luke, @remote_raphael)
    end

    context 'from the downstream author' do
      before do
        @comment = @local_leia.comment!(@local_parent, "yo")
        @retraction = @local_leia.retract(@comment)
        @recipient = @local_luke
      end

      it 'signs' do
        @retraction.should_receive(:sign_with_key) do |key|
          key.to_s.should ==  @recipient.encryption_key.to_s
        end
        @retraction.receive(@recipient, @comment.author)
      end

      it 'dispatches' do
        zord = mock()
        zord.should_receive(:post)
        Postzord::Dispatcher.should_receive(:build).with(@local_luke, @retraction).and_return zord
        @retraction.receive(@recipient, @comment.author)
      end

      it 'performs' do
        @retraction.should_receive(:perform).with(@local_luke)
        @retraction.receive(@recipient, @comment.author)
      end
    end

    context 'from the upstream owner' do
      before do
        @comment = @local_luke.comment!(@remote_parent, "Yeah, it was great")
        @retraction = RelayableRetraction.allocate
        @retraction.sender = @remote_raphael
        @retraction.target = @comment
        @retraction.stub!(:parent_author_signature_valid?).and_return(true)
        @recipient = @local_luke
      end

      it 'performs' do
        @retraction.should_receive(:perform).with(@recipient)
        @retraction.receive(@recipient, @remote_raphael)
      end

      it 'does not dispatch' do
        Postzord::Dispatcher.should_not_receive(:build)
        @retraction.receive(@recipient, @remote_raphael)
      end
    end
  end

  describe 'xml' do
    before do
      @comment = @local_leia.comment!(@local_parent, "yo")
      @retraction = RelayableRetraction.build(@local_leia, @comment)
      @retraction.parent_author_signature = 'PARENTSIGNATURE'
      @retraction.target_author_signature = 'TARGETSIGNATURE'
      @xml = @retraction.to_xml.to_s
    end

    describe '#to_xml' do
      it 'serializes target_guid' do
        @xml.should include(@comment.guid)
      end

      it 'serializes target_type' do
        @xml.should include(@comment.class.to_s)
      end

      it 'serializes sender_handle' do
        @xml.should include(@local_leia.diaspora_handle)
      end

      it 'serializes signatures' do
        @xml.should include('TARGETSIGNATURE')
        @xml.should include('PARENTSIGNATURE')
      end
    end

    describe '.from_xml' do
      before do
        @marshalled = RelayableRetraction.from_xml(@xml)
      end

      it 'marshals the target' do
        @marshalled.target.should == @comment
      end

      it 'marshals the sender' do
        @marshalled.sender.should == @local_leia.person
      end

      it 'marshals the signature' do
        @marshalled.target_author_signature.should == 'TARGETSIGNATURE'
        @marshalled.parent_author_signature.should == 'PARENTSIGNATURE'
      end
    end
  end
end
