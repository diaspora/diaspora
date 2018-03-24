# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe 'a user receives a post', :type => :request do
  before do
    @alices_aspect = alice.aspects.where(:name => "generic").first
    @bobs_aspect = bob.aspects.where(:name => "generic").first
    @eves_aspect = eve.aspects.where(:name => "generic").first
  end

  it 'should not create new aspects on message receive' do
    num_aspects = alice.aspects.size

    2.times do |n|
      status_message = bob.post :status_message, :text => "store this #{n}!", :to => @bobs_aspect.id
    end

    expect(alice.aspects.size).to eq(num_aspects)
  end

  it "should show bob's post to alice" do
    inlined_jobs do |queue|
      sm = bob.build_post(:status_message, :text => "hi")
      sm.save!
      bob.aspects.reload
      bob.add_to_streams(sm, [@bobs_aspect])
      queue.drain_all
      bob.dispatch_post(sm, :to => @bobs_aspect)
    end

    expect(alice.visible_shareables(Post).count(:all)).to eq(1)
  end

  describe 'post refs' do
    before do
      @status_message = bob.post(:status_message, :text => "hi", :to => @bobs_aspect.id)
    end

    it "adds a received post to the the user" do
      expect(alice.visible_shareables(Post)).to include(@status_message)
      expect(ShareVisibility.find_by(user_id: alice.id, shareable_id: @status_message.id)).not_to be_nil
    end

    it "does not remove visibility on disconnect" do
      contact = alice.contact_for(bob.person)
      alice.disconnect(contact)
      contact.destroy

      expect(ShareVisibility.exists?(user_id: alice.id, shareable_id: @status_message.id)).to be_truthy
    end
  end
end
