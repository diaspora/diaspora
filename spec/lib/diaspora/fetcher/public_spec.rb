# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "integration/federation/federation_helper"

# Tests fetching public posts of a person on a remote server
describe Diaspora::Fetcher::Public do
  let(:fixture) do
    File.read(Rails.root.join("spec/fixtures/public_posts.json"))
  end
  let(:fixture_data) do
    JSON.parse(fixture)
  end

  before do
    # the fixture is taken from an actual json request.
    # it contains 10 StatusMessages and 5 Reshares, all of them public
    # the guid of the person is "7445f9a0a6c28ebb"
    @fetcher = Diaspora::Fetcher::Public.new
    @person = FactoryBot.create(:person, guid:            "7445f9a0a6c28ebb",
                                         pod:             Pod.find_or_create_by(url: "https://remote-testpod.net"),
                                         diaspora_handle: "testuser@remote-testpod.net")

    stub_request(:get, %r{remote-testpod.net/people/.*/stream})
      .with(headers: {
              "Accept"          => "application/json",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent"      => "diaspora-fetcher"
            }).to_return(body: fixture)
  end

  describe "#queue_for" do
    it "queues a new job" do
      @person.fetch_status = Diaspora::Fetcher::Public::Status_Initial

      expect(Workers::FetchPublicPosts).to receive(:perform_async).with(@person.diaspora_handle)

      Diaspora::Fetcher::Public.queue_for(@person)
    end

    it "queues no job if the status is not initial" do
      @person.fetch_status = Diaspora::Fetcher::Public::Status_Done

      expect(Workers::FetchPublicPosts).not_to receive(:perform_async).with(@person.diaspora_handle)

      Diaspora::Fetcher::Public.queue_for(@person)
    end
  end

  describe "#retrieve_posts" do
    before do
      person = @person
      @fetcher.instance_eval {
        @person = person
        retrieve_posts
      }
    end

    it "sets the operation status on the person" do
      @person.reload
      expect(@person.fetch_status).not_to eql(Diaspora::Fetcher::Public::Status_Initial)
      expect(@person.fetch_status).to eql(Diaspora::Fetcher::Public::Status_Fetched)
    end

    it "sets the @data variable to the parsed JSON data" do
      data = @fetcher.instance_eval {
        @data
      }
      expect(data).not_to be_nil
      expect(data.size).to eq(fixture_data.size)
    end
  end

  describe "#process_posts" do
    before do
      person = @person
      data = fixture_data

      @fetcher.instance_eval {
        @person = person
        @data = data
      }

      fixture_data.each do |post_data|
        post = if post_data["post_type"] == "StatusMessage"
                 FactoryBot.build(
                   :status_message,
                   guid:       post_data["guid"],
                   text:       post_data["text"],
                   created_at: post_data["created_at"],
                   public:     true,
                   author:     eve.person
                 )
               else
                 reshare = FactoryBot.build(
                   :reshare,
                   guid:       post_data["guid"],
                   created_at: post_data["created_at"],
                   public:     true,
                   author:     eve.person
                 )
                 reshare.root.save
                 reshare
               end
        payload = generate_payload(Diaspora::Federation::Entities.post(post), eve)

        stub_request(:get, "https://remote-testpod.net/fetch/post/#{post_data['guid']}")
          .to_return(status: 200, body: payload)
      end
    end

    it "creates 15 new posts in the database" do
      expect {
        @fetcher.instance_eval {
          process_posts
        }
      }.to change(Post, :count).by(15)
    end

    it "sets the operation status on the person" do
      @fetcher.instance_eval {
        process_posts
      }

      @person.reload
      expect(@person.fetch_status).not_to eql(Diaspora::Fetcher::Public::Status_Initial)
      expect(@person.fetch_status).to eql(Diaspora::Fetcher::Public::Status_Processed)
    end

    context "created post" do
      before do
        Timecop.freeze
        @now = DateTime.now.utc

        # save posts to db
        @fetcher.instance_eval {
          process_posts
        }
      end

      after do
        Timecop.return
      end

      it "applies the date from JSON to the record" do
        fixture_data.each do |post|
          date = ActiveSupport::TimeZone.new("UTC").parse(post["created_at"]).to_i

          entry = Post.find_by(guid: post["guid"])
          expect(entry.created_at.to_i).to eql(date)
        end
      end

      it "copied the text of status messages correctly" do
        fixture_data.select {|item| item["post_type"] == "StatusMessage" }.each do |post|
          entry = StatusMessage.find_by(guid: post["guid"])
          expect(entry.text).to eql(post["text"])
        end
      end

      it "applies now to interacted_at on the record" do
        fixture_data.each do |post|
          date = @now.to_i

          entry = Post.find_by(guid: post["guid"])
          expect(entry.interacted_at.to_i).to eql(date)
        end
      end
    end
  end

  context "private methods" do
    let(:public_fetcher) { Diaspora::Fetcher::Public.new }

    describe "#qualifies_for_fetching?" do
      it "raises an error if the person doesn't exist" do
        expect {
          public_fetcher.instance_eval {
            @person = Person.by_account_identifier "someone@unknown.com"
            qualifies_for_fetching?
          }
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it "returns false if the person is unfetchable" do
        expect(public_fetcher.instance_eval {
          @person = FactoryBot.create(:person, fetch_status: Diaspora::Fetcher::Public::Status_Unfetchable)
          qualifies_for_fetching?
        }).to be false
      end

      it "returns false and sets the person unfetchable for a local account" do
        user = FactoryBot.create(:user)
        expect(public_fetcher.instance_eval {
          @person = user.person
          qualifies_for_fetching?
        }).to be false
        expect(user.person.fetch_status).to eql Diaspora::Fetcher::Public::Status_Unfetchable
      end

      it "returns false if the person is processing already (or has been processed)" do
        person = FactoryBot.create(:person)
        person.fetch_status = Diaspora::Fetcher::Public::Status_Fetched
        person.save
        expect(public_fetcher.instance_eval {
          @person = person
          qualifies_for_fetching?
        }).to be false
      end

      it "returns true, if the user is remote and hasn't been fetched" do
        person = FactoryBot.create(:person, {diaspora_handle: "neo@theone.net"})
        expect(public_fetcher.instance_eval {
          @person = person
          qualifies_for_fetching?
        }).to be true
      end
    end

    describe "#set_fetch_status" do
      it "sets the current status of fetching on the person" do
        person = @person
        public_fetcher.instance_eval {
          @person = person
          set_fetch_status Diaspora::Fetcher::Public::Status_Unfetchable
        }
        expect(@person.fetch_status).to eql Diaspora::Fetcher::Public::Status_Unfetchable

        public_fetcher.instance_eval {
          set_fetch_status Diaspora::Fetcher::Public::Status_Initial
        }
        expect(@person.fetch_status).to eql Diaspora::Fetcher::Public::Status_Initial
      end
    end

    describe "#validate" do
      it "calls all validation helper methods" do
        expect(public_fetcher).to receive(:check_existing).and_return(true)
        expect(public_fetcher).to receive(:check_author).and_return(true)
        expect(public_fetcher).to receive(:check_public).and_return(true)

        expect(public_fetcher.instance_eval { validate({}) }).to be true
      end
    end

    describe "#check_existing" do
      it "returns false if a post with the same guid exists" do
        post = {"guid" => FactoryBot.create(:status_message).guid}
        expect(public_fetcher.instance_eval { check_existing post }).to be false
      end

      it "returns true if the guid cannot be found" do
        post = {"guid" => SecureRandom.hex(8)}
        expect(public_fetcher.instance_eval { check_existing post }).to be true
      end
    end

    describe "#check_author" do
      let!(:some_person) { FactoryBot.create(:person) }

      before do
        person = some_person
        public_fetcher.instance_eval { @person = person }
      end

      it "returns false if the person doesn't match" do
        post = {"author" => {"guid" => SecureRandom.hex(8)}}
        expect(public_fetcher.instance_eval { check_author post }).to be false
      end

      it "returns true if the persons match" do
        post = {"author" => {"guid" => some_person.guid}}
        expect(public_fetcher.instance_eval { check_author post }).to be true
      end
    end

    describe "#check_public" do
      it "returns false if the post is not public" do
        post = {"public" => false}
        expect(public_fetcher.instance_eval { check_public post }).to be false
      end

      it "returns true if the post is public" do
        post = {"public" => true}
        expect(public_fetcher.instance_eval { check_public post }).to be true
      end
    end
  end
end
