require 'helper'

describe Twitter::Client do
  context ".new" do
    before do
      @client = Twitter::Client.new(:consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
    end

    describe ".places_nearby" do

      before do
        stub_get("geo/search.json").
          with(:query => {:ip => "74.125.19.104"}).
          to_return(:body => fixture("places.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should get the correct resource" do
        @client.places_nearby(:ip => "74.125.19.104")
        a_get("geo/search.json").
          with(:query => {:ip => "74.125.19.104"}).
          should have_been_made
      end

      it "should return nearby places" do
        places = @client.places_nearby(:ip => "74.125.19.104")
        places.should be_an Array
        places.first.name.should == "Bernal Heights"
      end

    end

    describe ".places_similar" do

      before do
        stub_get("geo/similar_places.json").
          with(:query => {:lat => "37.7821120598956", :long => "-122.400612831116", :name => "Twitter HQ"}).
          to_return(:body => fixture("places.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should get the correct resource" do
        @client.places_similar(:lat => "37.7821120598956", :long => "-122.400612831116", :name => "Twitter HQ")
        a_get("geo/similar_places.json").
          with(:query => {:lat => "37.7821120598956", :long => "-122.400612831116", :name => "Twitter HQ"}).
          should have_been_made
      end

      it "should return similar places" do
        places = @client.places_similar(:lat => "37.7821120598956", :long => "-122.400612831116", :name => "Twitter HQ")
        places.should be_a Hash
        places[:places].first.name.should == "Bernal Heights"
      end

    end

    describe ".reverse_geocode" do

      before do
        stub_get("geo/reverse_geocode.json").
          with(:query => {:lat => "37.7821120598956", :long => "-122.400612831116"}).
          to_return(:body => fixture("places.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should get the correct resource" do
        @client.reverse_geocode(:lat => "37.7821120598956", :long => "-122.400612831116")
        a_get("geo/reverse_geocode.json").
          with(:query => {:lat => "37.7821120598956", :long => "-122.400612831116"}).
          should have_been_made
      end

      it "should return places" do
        places = @client.reverse_geocode(:lat => "37.7821120598956", :long => "-122.400612831116")
        places.should be_an Array
        places.first.name.should == "Bernal Heights"
      end

    end

    describe ".place" do

      before do
        stub_get("geo/id/247f43d441defc03.json").
          to_return(:body => fixture("place.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should get the correct resource" do
        @client.place("247f43d441defc03")
        a_get("geo/id/247f43d441defc03.json").
          should have_been_made
      end

      it "should return a place" do
        place = @client.place("247f43d441defc03")
        place.name.should == "Twitter HQ"
      end

    end

    describe ".place_create" do

      before do
        stub_post("geo/place.json").
          with(:body => {:name => "@sferik's Apartment", :token => "22ff5b1f7159032cf69218c4d8bb78bc", :contained_within => "41bcb736f84a799e", :lat => "37.783699", :long => "-122.393581"}).
          to_return(:body => fixture("place.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should get the correct resource" do
        @client.place_create(:name => "@sferik's Apartment", :token => "22ff5b1f7159032cf69218c4d8bb78bc", :contained_within => "41bcb736f84a799e", :lat => "37.783699", :long => "-122.393581")
        a_post("geo/place.json").
          with(:body => {:name => "@sferik's Apartment", :token => "22ff5b1f7159032cf69218c4d8bb78bc", :contained_within => "41bcb736f84a799e", :lat => "37.783699", :long => "-122.393581"}).
          should have_been_made
      end

      it "should return a place" do
        place = @client.place_create(:name => "@sferik's Apartment", :token => "22ff5b1f7159032cf69218c4d8bb78bc", :contained_within => "41bcb736f84a799e", :lat => "37.783699", :long => "-122.393581")
        place.name.should == "Twitter HQ"
      end

    end

  end
end
