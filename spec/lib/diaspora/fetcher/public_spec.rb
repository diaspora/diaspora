# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Tests fetching public posts of a person on a remote server
describe Diaspora::Fetcher::Public do
  before do
    # the fixture is taken from an actual json request.
    # it contains 10 StatusMessages and 5 Reshares, all of them public
    # the guid of the person is "7445f9a0a6c28ebb"
    @fixture = File.open(Rails.root.join('spec', 'fixtures', 'public_posts.json')).read
    @fetcher = Diaspora::Fetcher::Public.new
    @person = FactoryGirl.create(:person, guid:            "7445f9a0a6c28ebb",
                                          pod:             Pod.find_or_create_by(url: "https://remote-testpod.net"),
                                          diaspora_handle: "testuser@remote-testpod.net")

    stub_request(:get, /remote-testpod.net\/people\/.*\/stream/)
      .with(headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'diaspora-fetcher'
      }).to_return(:body => @fixture)
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
      expect(data.size).to eql JSON.parse(@fixture).size
    end
  end

  describe "#process_posts" do
    before do
      person = @person
      data = JSON.parse(@fixture)

      @fetcher.instance_eval {
        @person = person
        @data = data
      }
    end

    it 'creates 10 new posts in the database' do
      before_count = Post.count
      @fetcher.instance_eval {
        process_posts
      }
      after_count = Post.count
      expect(after_count).to eql(before_count + 10)
    end

    it 'sets the operation status on the person' do
      @fetcher.instance_eval {
        process_posts
      }

      @person.reload
      expect(@person.fetch_status).not_to eql(Diaspora::Fetcher::Public::Status_Initial)
      expect(@person.fetch_status).to eql(Diaspora::Fetcher::Public::Status_Processed)
    end

    context 'created post' do
      before do
        Timecop.freeze
        @now = DateTime.now.utc
        @data = JSON.parse(@fixture).select { |item| item['post_type'] == 'StatusMessage' }

        #save posts to db
        @fetcher.instance_eval {
          process_posts
        }
      end

      after do
        Timecop.return
      end

      it 'applies the date from JSON to the record' do
        @data.each do |post|
          date = ActiveSupport::TimeZone.new('UTC').parse(post['created_at']).to_i

          entry = StatusMessage.find_by_guid(post['guid'])
          expect(entry.created_at.to_i).to eql(date)
        end
      end

      it "copied the text correctly" do
        @data.each do |post|
          entry = StatusMessage.find_by_guid(post["guid"])
          expect(entry.text).to eql(post["text"])
        end
      end

      it 'applies now to interacted_at on the record' do
        @data.each do |post|
          date = @now.to_i

          entry = StatusMessage.find_by_guid(post['guid'])
          expect(entry.interacted_at.to_i).to eql(date)
        end
      end
    end
  end

  context "private methods" do
    let(:public_fetcher) { Diaspora::Fetcher::Public.new }

    describe '#qualifies_for_fetching?' do
      it "raises an error if the person doesn't exist" do
        expect {
          public_fetcher.instance_eval {
            @person = Person.by_account_identifier "someone@unknown.com"
            qualifies_for_fetching?
          }
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'returns false if the person is unfetchable' do
        expect(public_fetcher.instance_eval {
          @person = FactoryGirl.create(:person, {:fetch_status => Diaspora::Fetcher::Public::Status_Unfetchable})
          qualifies_for_fetching?
        }).to be false
      end

      it 'returns false and sets the person unfetchable for a local account' do
        user = FactoryGirl.create(:user)
        expect(public_fetcher.instance_eval {
          @person = user.person
          qualifies_for_fetching?
        }).to be false
        expect(user.person.fetch_status).to eql Diaspora::Fetcher::Public::Status_Unfetchable
      end

      it 'returns false if the person is processing already (or has been processed)' do
        person = FactoryGirl.create(:person)
        person.fetch_status = Diaspora::Fetcher::Public::Status_Fetched
        person.save
        expect(public_fetcher.instance_eval {
          @person = person
          qualifies_for_fetching?
        }).to be false
      end

      it "returns true, if the user is remote and hasn't been fetched" do
        person = FactoryGirl.create(:person, {:diaspora_handle => 'neo@theone.net'})
        expect(public_fetcher.instance_eval {
          @person = person
          qualifies_for_fetching?
        }).to be true
      end
    end

    describe '#set_fetch_status' do
      it 'sets the current status of fetching on the person' do
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

    describe '#validate' do
      it "calls all validation helper methods" do
        expect(public_fetcher).to receive(:check_existing).and_return(true)
        expect(public_fetcher).to receive(:check_author).and_return(true)
        expect(public_fetcher).to receive(:check_public).and_return(true)
        expect(public_fetcher).to receive(:check_type).and_return(true)

        expect(public_fetcher.instance_eval { validate({}) }).to be true
      end
    end

    describe '#check_existing' do
      it 'returns false if a post with the same guid exists' do
        post = {'guid' => FactoryGirl.create(:status_message).guid}
        expect(public_fetcher.instance_eval { check_existing post }).to be false
      end

      it 'returns true if the guid cannot be found' do
        post = {'guid' => SecureRandom.hex(8)}
        expect(public_fetcher.instance_eval { check_existing post }).to be true
      end
    end

    describe '#check_author' do
      let!(:some_person) { FactoryGirl.create(:person) }

      before do
        person = some_person
        public_fetcher.instance_eval { @person = person }
      end

      it "returns false if the person doesn't match" do
        post = { 'author' => { 'guid' => SecureRandom.hex(8) } }
        expect(public_fetcher.instance_eval { check_author post }).to be false
      end

      it "returns true if the persons match" do
        post = { 'author' => { 'guid' => some_person.guid } }
        expect(public_fetcher.instance_eval { check_author post }).to be true
      end
    end

    describe '#check_public' do
      it "returns false if the post is not public" do
        post = {'public' => false}
        expect(public_fetcher.instance_eval { check_public post }).to be false
      end

      it "returns true if the post is public" do
        post = {'public' => true}
        expect(public_fetcher.instance_eval { check_public post }).to be true
      end
    end

    describe '#check_type' do
      it "returns false if the type is anything other that 'StatusMessage'" do
        post = {'post_type'=>'Reshare'}
        expect(public_fetcher.instance_eval { check_type post }).to be false
      end

      it "returns true if the type is 'StatusMessage'" do
        post = {'post_type'=>'StatusMessage'}
        expect(public_fetcher.instance_eval { check_type post }).to be true
      end
    end
  end
end
