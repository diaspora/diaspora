#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, "spec", "shared_behaviors", "relayable")

describe RelayableRetraction do
  before do
    @local_luke, @local_leia, @remote_raphael = set_up_friends
    @remote_parent = Factory.create(:status_message, :author => @remote_raphael)
    @local_parent = @local_luke.post :status_message, :text => "hi", :to => @local_luke.aspects.first
    @comment_by_parent_author = @local_luke.comment("yo", :on => @local_parent)
    @retraction_by_parent_author = @local_luke.retract(@comment_by_parent_author)

    @comment_by_recipient = @local_leia.build_comment("yo", :on => @local_parent)
    @retraction_by_recipient = @local_leia.retract(@comment_by_recipient)

    @comment_on_remote_parent = @local_luke.comment("Yeah, it was great", :on => @remote_parent)
    @retraction_from_remote_author = RelayableRetraction.new(@remote_raphael, @comment_on_remote_parent)
  end

  describe '#subscribers' do
    it 'delegates it to target' do
      arg = mock()
      @retraction_by_parent_author.target.should_receive(:subscribers).with(arg)
      @retraction_by_parent_author.subscribers(arg)
    end
  end

  describe '#receive' do
    context 'from the downstream author' do
      it 'signs' do

      end
      it 'dispatches' do

      end
      it 'performs' do

      end
    end
    context 'from the upstream owner' do
      it 'performs' do

      end
      it 'does not dispatch' do

      end
    end
  end

  describe 'xml' do
    describe '#to_xml' do

    end
    describe '.from_xml' do

    end
  end
end
