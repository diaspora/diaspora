# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe PhotosController, :type => :controller do
  before do
    @alices_photo = alice.post(:photo, :user_file => uploaded_photo, :to => alice.aspects.first.id, :public => false)
    sign_in alice, scope: :user
  end

  describe '#index' do
    it "generates a jasmine fixture", :fixture => true do
      request.env['HTTP_ACCEPT'] = 'application/json'
      get :index, params: {person_id: alice.person.guid.to_s}
      save_fixture(response.body, "photos_json")
    end
  end
end
