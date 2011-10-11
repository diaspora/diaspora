require 'spec_helper'

describe NotesController do
  before do
    @aspect1 = alice.aspects.first
    @aspect2 = bob.aspects.first

    request.env["HTTP_REFERER"] = ""
    sign_in :user, alice
    @controller.stub!(:current_user).and_return(alice)
    alice.reload
  end

  describe 'index' do
    it "should be successful" do
      get :index
      response.should be_success
    end

    it 'assings new NoteStream' do
      get :index
      assigns[:stream].should be_a NoteStream
    end

    it 'renders a view' do
      get :index
      response.body.should_not be_blank
    end
  end
end
