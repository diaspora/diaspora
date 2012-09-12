#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join('lib','diaspora','fetcher','public')
require 'spec_helper'

# Tests fetching public posts of a person on a remote server
describe PublicFetcher do
  before do

    # the fixture is taken from an actual json request.
    # it contains 10 StatusMessages and 5 Reshares, all of them public
    # the guid of the person is "7445f9a0a6c28ebb"
    @fixture = File.open(Rails.root.join('spec', 'fixtures', 'public_posts.json')).read
    @fetcher = PublicFetcher.new
    @person = FactoryGirl.create(:person, {:guid => "7445f9a0a6c28ebb",
                                :url => "https://remote-testpod.net",
                                :diaspora_handle => "testuser@remote-testpod.net"})

    stub_request(:get, /remote-testpod.net\/people\/.*/)
      .with(:headers => {'Accept'=>'application/json'})
      .to_return(:body => @fixture)
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
      @person.fetch_status.should_not eql(PublicFetcher::Status_Initial)
      @person.fetch_status.should eql(PublicFetcher::Status_Fetched)
    end

    it "sets the @data variable to the parsed JSON data" do
      data = @fetcher.instance_eval {
        @data
      }
      data.should_not be_nil
      data.size.should eql JSON.parse(@fixture).size
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
      after_count.should eql(before_count + 10)
    end

    it 'sets the operation status on the person' do
      @fetcher.instance_eval {
        process_posts
      }

      @person.reload
      @person.fetch_status.should_not eql(PublicFetcher::Status_Initial)
      @person.fetch_status.should eql(PublicFetcher::Status_Processed)
    end

    context 'created post' do
      before do
        @data = JSON.parse(@fixture).select { |item| item['post_type'] == 'StatusMessage' }

        #save posts to db
        @fetcher.instance_eval {
          process_posts
        }
      end
      
      it 'applies the date from JSON to the record' do
        @data.each do |post|
          date = ActiveSupport::TimeZone.new('UTC').parse(post['created_at'])

          entry = StatusMessage.find_by_guid(post['guid'])
          entry.created_at.should eql(date)
        end
      end

      it 'copied the text correctly' do
        @data.each do |post|
          entry = StatusMessage.find_by_guid(post['guid'])
          entry.raw_message.should eql(post['text'])
        end
      end
    end
  end

  context "private methods" do
    let(:public_fetcher) { PublicFetcher.new }

    describe '#qualifies_for_fetching?' do
      it "raises an error if the person doesn't exist" do
        lambda {
          public_fetcher.instance_eval {
            @person = Person.by_account_identifier "someone@unknown.com"
            qualifies_for_fetching?
          }
        }.should raise_error ActiveRecord::RecordNotFound
      end

      it 'returns false if the person is unfetchable' do
        public_fetcher.instance_eval {
          @person = FactoryGirl.create(:person, {:fetch_status => PublicFetcher::Status_Unfetchable})
          qualifies_for_fetching?
        }.should be_false
      end

      it 'returns false and sets the person unfetchable for a local account' do
        user = FactoryGirl.create(:user)
        public_fetcher.instance_eval {
          @person = user.person
          qualifies_for_fetching?
        }.should be_false
        user.person.fetch_status.should eql PublicFetcher::Status_Unfetchable
      end

      it 'returns false if the person is processing already (or has been processed)' do
        person = FactoryGirl.create(:person)
        person.fetch_status = PublicFetcher::Status_Fetched
        person.save
        public_fetcher.instance_eval {
          @person = person
          qualifies_for_fetching?
        }.should be_false
      end

      it "returns true, if the user is remote and hasn't been fetched" do
        person = FactoryGirl.create(:person, {:diaspora_handle => 'neo@theone.net'})
        public_fetcher.instance_eval {
          @person = person
          qualifies_for_fetching?
        }.should be_true
      end
    end

    describe '#set_fetch_status' do
      it 'sets the current status of fetching on the person' do
        person = @person
        public_fetcher.instance_eval {
          @person = person
          set_fetch_status PublicFetcher::Status_Unfetchable
        }
        @person.fetch_status.should eql PublicFetcher::Status_Unfetchable

        public_fetcher.instance_eval {
          set_fetch_status PublicFetcher::Status_Initial
        }
        @person.fetch_status.should eql PublicFetcher::Status_Initial
      end
    end

    describe '#validate' do
      it "calls all validation helper methods" do
        public_fetcher.should_receive(:check_existing).and_return(true)
        public_fetcher.should_receive(:check_author).and_return(true)
        public_fetcher.should_receive(:check_public).and_return(true)
        public_fetcher.should_receive(:check_type).and_return(true)

        public_fetcher.instance_eval { validate({}) }.should be_true
      end
    end

    describe '#check_existing' do
      it 'returns false if a post with the same guid exists' do
        post = {'guid' => FactoryGirl.create(:status_message).guid}
        public_fetcher.instance_eval { check_existing post }.should be_false
      end

      it 'returns true if the guid cannot be found' do
        post = {'guid' => SecureRandom.hex(8)}
        public_fetcher.instance_eval { check_existing post }.should be_true
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
        public_fetcher.instance_eval { check_author post }.should be_false
      end

      it "returns true if the persons match" do
        post = { 'author' => { 'guid' => some_person.guid } }
        public_fetcher.instance_eval { check_author post }.should be_true
      end
    end

    describe '#check_public' do
      it "returns false if the post is not public" do
        post = {'public' => false}
        public_fetcher.instance_eval { check_public post }.should be_false
      end

      it "returns true if the post is public" do
        post = {'public' => true}
        public_fetcher.instance_eval { check_public post }.should be_true
      end
    end

    describe '#check_type' do
      it "returns false if the type is anything other that 'StatusMessage'" do
        post = {'post_type'=>'Reshare'}
        public_fetcher.instance_eval { check_type post }.should be_false
      end

      it "returns true if the type is 'StatusMessage'" do
        post = {'post_type'=>'StatusMessage'}
        public_fetcher.instance_eval { check_type post }.should be_true
      end
    end
  end
end