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
        expect(@retraction.target).to receive(:parent)
        @retraction.parent
      end
    end

    describe "#parent_author" do
      it "delegates to target" do
        expect(@retraction.target).to receive(:parent_author)
        @retraction.parent_author
      end
    end

    describe '#subscribers' do
      it 'delegates it to target' do
        arg = double()
        expect(@retraction.target).to receive(:subscribers).with(arg)
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
      expect(@retraction).not_to receive(:perform)
      @retraction.receive(@local_luke, @remote_raphael)
    end

    context 'from the downstream author' do
      before do
        @comment = @local_leia.comment!(@local_parent, "yo")
        @retraction = @local_leia.retract(@comment)
        @recipient = @local_luke
      end

      it 'signs' do
        expect(@retraction).to receive(:sign_with_key) do |key|
          expect(key.to_s).to eq(@recipient.encryption_key.to_s)
        end
        @retraction.receive(@recipient, @comment.author)
      end

      it 'dispatches' do
        zord = double()
        expect(zord).to receive(:post)
        expect(Postzord::Dispatcher).to receive(:build).with(@local_luke, @retraction).and_return zord
        @retraction.receive(@recipient, @comment.author)
      end

      it 'performs' do
        expect(@retraction).to receive(:perform).with(@local_luke)
        @retraction.receive(@recipient, @comment.author)
      end
    end

    context 'from the upstream owner' do
      before do
        @comment = @local_luke.comment!(@remote_parent, "Yeah, it was great")
        @retraction = described_class.allocate
        @retraction.sender = @remote_raphael
        @retraction.target = @comment
        allow(@retraction).to receive(:parent_author_signature_valid?).and_return(true)
        @recipient = @local_luke
      end

      it 'performs' do
        expect(@retraction).to receive(:perform).with(@recipient)
        @retraction.receive(@recipient, @remote_raphael)
      end

      it 'does not dispatch' do
        expect(Postzord::Dispatcher).not_to receive(:build)
        @retraction.receive(@recipient, @remote_raphael)
      end

      it 'performs through postzord' do
        xml = Salmon::Slap.create_by_user_and_activity(@local_luke, @retraction.to_diaspora_xml).xml_for(nil)
        expect {
          Postzord::Receiver::Public.new(xml).perform!
        }.to change(Comment, :count).by(-1)
      end
    end
  end

  describe 'xml' do
    before do
      @comment = @local_leia.comment!(@local_parent, "yo")
      @retraction = described_class.build(@local_leia, @comment)
      @retraction.parent_author_signature = 'PARENTSIGNATURE'
      @retraction.target_author_signature = 'TARGETSIGNATURE'
      @xml = @retraction.to_xml.to_s
    end

    describe '#to_xml' do
      it 'serializes target_guid' do
        expect(@xml).to include(@comment.guid)
      end

      it 'serializes target_type' do
        expect(@xml).to include(@comment.class.to_s)
      end

      it 'serializes sender_handle' do
        expect(@xml).to include(@local_leia.diaspora_handle)
      end

      it 'serializes signatures' do
        expect(@xml).to include('TARGETSIGNATURE')
        expect(@xml).to include('PARENTSIGNATURE')
      end
    end

    describe '.from_xml' do
      before do
        @marshalled = described_class.from_xml(@xml)
      end

      it 'marshals the target' do
        expect(@marshalled.target).to eq(@comment)
      end

      it 'marshals the sender' do
        expect(@marshalled.sender).to eq(@local_leia.person)
      end

      it 'marshals the signature' do
        expect(@marshalled.target_author_signature).to eq('TARGETSIGNATURE')
        expect(@marshalled.parent_author_signature).to eq('PARENTSIGNATURE')
      end
    end
  end
end
