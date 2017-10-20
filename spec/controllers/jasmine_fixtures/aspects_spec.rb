# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe StreamsController, :type => :controller do
  describe '#aspects' do
    before do
      sign_in alice, scope: :user
      @alices_aspect_2 = alice.aspects.create(:name => "another aspect")

      request.env["HTTP_REFERER"] = 'http://' + request.host
    end

    context 'jasmine fixtures' do
      before do
        allow_any_instance_of(Stream::Aspect).to receive(:ajax_stream?).and_return(false)
      end

      it "generates a jasmine fixture", :fixture => true do
        get :aspects
        save_fixture(html_for("body"), "aspects_index")
      end

      it "generates a jasmine fixture with a prefill", :fixture => true do
        get :aspects, params: {prefill: "reshare things"}
        save_fixture(html_for("body"), "aspects_index_prefill")
      end

      it 'generates a jasmine fixture with services', :fixture => true do
        alice.services << Services::Facebook.create(:user_id => alice.id)
        alice.services << Services::Twitter.create(:user_id => alice.id)
        get :aspects, params: {prefill: "reshare things"}
        save_fixture(html_for("body"), "aspects_index_services")
      end

      it 'generates a jasmine fixture with posts', :fixture => true do
        bob.post(:status_message, :text => "Is anyone out there?", :to => @bob.aspects.where(:name => "generic").first.id)
        message = alice.post(:status_message, :text => "hello "*800, :to => @alices_aspect_2.id)
        5.times { bob.comment!(message, "what") }
        get :aspects
        save_fixture(html_for("body"), "aspects_index_with_posts")
      end

      it 'generates a jasmine fixture with only posts', :fixture => true do
        2.times { bob.post(:status_message, :text => "Is anyone out there?", :to => @bob.aspects.where(:name => "generic").first.id) }

        get :aspects, params: {only_posts: true}

        save_fixture(response.body, "aspects_index_only_posts")
      end

      it "generates a jasmine fixture with a post with comments", :fixture => true do
        message = bob.post(:status_message, :text => "HALO WHIRLED", :to => @bob.aspects.where(:name => "generic").first.id)
        5.times { bob.comment!(message, "what") }
        get :aspects
        save_fixture(html_for("body"), "aspects_index_post_with_comments")
      end

      it "generates a mobile jasmine fixture with a post with comments", fixture: true do
        message = bob.post(:status_message, text: "HALO WHIRLED", to: @bob.aspects.where(name: "generic").first.id)
        5.times { bob.comment!(message, "what") }
        get :aspects, format: :mobile
        save_fixture(html_for("body"), "aspects_index_mobile_post_with_comments")
      end

      it "generates a mobile jasmine fixture with a public post", fixture: true do
        message = bob.post(:status_message, text: "HALO WHIRLED", public: true)
        5.times { bob.comment!(message, "what") }
        get :aspects, format: :mobile
        save_fixture(html_for("body"), "aspects_index_mobile_public_post")
      end

      it "generates a mobile jasmine fixture with an NSFW post", fixture: true do
        message = bob.post(:status_message, text: "#NSFW", to: @bob.aspects.where(name: "generic").first.id)
        5.times { bob.comment!(message, "what") }
        get :aspects, format: :mobile
        save_fixture(html_for("body"), "aspects_index_mobile_nsfw_post")
      end

      it 'generates a jasmine fixture with a followed tag', :fixture => true do
        @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
        TagFollowing.create!(:tag => @tag, :user => alice)
        get :aspects
        save_fixture(html_for("body"), "aspects_index_with_one_followed_tag")
      end

      it "generates a jasmine fixture with a post containing a video", :fixture => true do
        stub_request(
          :get,
          "https://www.youtube.com/oembed?format=json&frame=1&iframe=1&maxheight=420&maxwidth=420&scheme=https&url=http://www.youtube.com/watch?v=UYrkQL1bX4A"
        ).with(
          :headers => {'Accept'=>'*/*'}
        ).to_return(
          :status  => 200,
          :body    => '{ "title": "LazyTown song - Cooking By The Boo" }',
          :headers => {}
        )

        alice.post(:status_message, :text => "http://www.youtube.com/watch?v=UYrkQL1bX4A", :to => @alices_aspect_2.id)
        get :aspects
        save_fixture(html_for("body"), "aspects_index_with_video_post")
      end

      it "generates a jasmine fixture with a post that has been liked", :fixture => true do
        message = alice.post(:status_message, :text => "hello "*800, :to => @alices_aspect_2.id)
        alice.like!(message)
        bob.like!(message)

        get :aspects
        save_fixture(html_for("body"), "aspects_index_with_a_post_with_likes")
      end
    end
  end
end
