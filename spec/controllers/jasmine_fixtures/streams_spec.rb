#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StreamsController do
  describe '#multi' do
    before do
      sign_in :user, alice
    end

    it 'generates the stream_json fixture', :fixture => true do
      posts = []

      time = Time.now

      10.times do |i|
        Timecop.travel time += 1.day do
          Timecop.travel time += 1.minute
          posts << alice.post(:status_message, :text => "hella infos yo!", :to => alice.aspects.first.id)
          Timecop.travel time += 1.minute
          posts << alice.post(:reshare, :root_guid => FactoryGirl.create(:status_message, :public => true).guid, :to => 'all')
          Timecop.travel time += 1.minute
          if i == 9
            posts << alice.post(:status_message,
                                :text => "LONG POST TO TEST SHOW MORE. Cardigan trust fund vice, sartorial twee pitchfork +1 quinoa whatever readymade gluten-free. Seitan brooklyn mustache quinoa carles. Gentrify ethical four loko you probably haven't heard of them 3 wolf moon helvetica. Terry richardson +1 artisan, raw denim iphone four loko leggings organic helvetica retro mcsweeney's put a bird on it skateboard 3 wolf moon. Fap skateboard high life 8-bit. Iphone ethical tumblr lo-fi, dreamcatcher irony whatever farm-to-table mustache tofu marfa. Before they sold out next level lomo farm-to-table leggings, williamsburg jean shorts messenger bag. Synth readymade Austin artisan art party, cardigan vice mustache 3 wolf moon craft beer. Messenger bag before they sold out tattooed wayfarers viral photo booth. Food truck master cleanse locavore raw denim. Sustainable master cleanse seitan, trust fund cred yr keffiyeh butcher mlkshk put a bird on it gentrify you probably haven't heard of them vinyl craft beer gluten-free. Master cleanse retro next level messenger bag craft beer. DIY leggings dreamcatcher lo-fi. Etsy carles tattooed mcsweeney's food truck DIY wolf shoreditch.",
                                :to => alice.aspects.first.id)
          elsif i == 8
            posts << alice.post(:status_message,
                                :to => alice.aspects.first.id,
                                :text => <<TXT
LONG POST TO TEST SHOW MORE WITH BULLETS.
<ul>
  <li>Cardigan trust fund vice, sartorial twee pitchfork +1 quinoa whatever readymade gluten-free.</li>
  <li>Seitan brooklyn mustache quinoa carles.</li>
  <li>Gentrify ethical four loko you probably haven't heard of them 3 wolf moon helvetica.</li>
  <li>Terry richardson +1 artisan, raw denim iphone four loko leggings organic helvetica retro mcsweeney's put a bird on it skateboard 3 wolf moon.</li>
  <li>Fap skateboard high life 8-bit</li>
  <li>Iphone ethical tumblr lo-fi, dreamcatcher irony whatever farm-to-table mustache tofu marfa.</li>
  <li>Before they sold out next level lomo farm-to-table leggings, williamsburg jean shorts messenger bag.</li>
  <li>Synth readymade Austin artisan art party, cardigan vice mustache 3 wolf moon craft beer.</li>
</ul>
TXT
            )
          else
            posts << alice.post(:status_message, :text => "you're gonna love this.", :to => alice.aspects.first.id)
          end
          Timecop.travel time += 1.minute
          alice.like!(posts.last)
        end
      end

      get :multi, :format => :json
      response.should be_success
      save_fixture(response.body, "stream_json")

      Timecop.return
    end
  end
end
