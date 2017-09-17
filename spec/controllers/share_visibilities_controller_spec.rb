# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ShareVisibilitiesController, :type => :controller do
  before do
    @status = alice.post(:status_message, :text => "hello", :to => alice.aspects.first)
  end

  describe '#update' do
    context "on a post you can see" do
      before do
        sign_in(bob, scope: :user)
      end

      it 'succeeds' do
        put :update, params: {id: 42, post_id: @status.id}, format: :js
        expect(response).to be_success
      end

      it 'it calls toggle_hidden_shareable' do
        expect(@controller.current_user).to receive(:toggle_hidden_shareable).with(an_instance_of(StatusMessage))
        put :update, params: {id: 42, post_id: @status.id}, format: :js
      end
    end

    context "on a post you can't see" do
      before do
        sign_in(eve, scope: :user)
      end

      it "raises an error" do
        expect {
          put :update, params: {id: 42, post_id: @status.id}, format: :js
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "it doesn't call toggle_hidden_shareable" do
        expect(@controller.current_user).not_to receive(:toggle_hidden_shareable).with(an_instance_of(StatusMessage))
        begin
          put :update, params: {id: 42, post_id: @status.id}, format: :js
        rescue ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
