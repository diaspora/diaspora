#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MultisController do
  describe '#index' do
    before do
      sign_in :user, alice
    end

    it 'generates the multi_stream_json fixture', :fixture => true do
      posts = []

      posts << alice.post(:status_message, :text => "hella infos yo!", :to => alice.aspects.first.id)
      posts << alice.post(:reshare, :root_guid => Factory(:status_message, :public => true).guid, :to => 'all')
      posts << alice.post(:status_message, :text => "you're gonna love this.'", :to => alice.aspects.first.id)
      alice.like(1, :target => posts.last)

      time = Time.now
      posts.each do |p|
        time += 1.day
        p.stub(:created_at).and_return(time)
      end

      get :index, :format => :json
      response.should be_success

      pp response.body

      save_fixture(response.body, "multi_stream_json")
    end
  end
end
