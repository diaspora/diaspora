require 'test_helper'

class GeoTest < Test::Unit::TestCase
  include Twitter

  context "Geographic place lookup" do

    should "work" do
      stub_get 'http://api.twitter.com/1/geo/id/ea76a36c5bc2bdff.json', 'geo_place.json'
      place = Geo.place('ea76a36c5bc2bdff')
      assert_equal 'The United States of America', place.country
      assert_equal 'Ballantyne West, Charlotte', place.full_name
      assert_kind_of Array, place.geometry.coordinates
    end

  end

  context "Geographic search" do

    should "work" do
      stub_get 'http://api.twitter.com/1/geo/search.json?lat=35.061161&long=-80.854568', 'geo_search.json'
      places = Geo.search(:lat => 35.061161, :long => -80.854568)
      assert_equal 3, places.size
      assert_equal 'Ballantyne West, Charlotte', places[0].full_name
      assert_equal 'Ballantyne West', places[0].name
    end

    should "be able to search with free form text" do
      stub_get 'http://api.twitter.com/1/geo/search.json?query=princeton%20record%20exchange', 'geo_search_query.json'
      places = Geo.search(:query => 'princeton record exchange')
      assert_equal 1, places.size
      assert_equal 'Princeton Record Exchange', places[0].name
      assert_equal 'poi', places[0].place_type
      assert_equal '20 S Tulane St', places[0].attributes.street_address
    end

    should "be able to search by ip address" do
      stub_get 'http://api.twitter.com/1/geo/search.json?ip=74.125.19.104', 'geo_search_ip_address.json'
      places = Geo.search(:ip => '74.125.19.104')
      assert_equal 4, places.size
      assert_equal 'Mountain View, CA', places[0].full_name
      assert_equal 'Mountain View', places[0].name
      assert_equal 'Sunnyvale, CA', places[1].full_name
      assert_equal 'Sunnyvale', places[1].name
    end

  end

  context "Geographic reverse_geocode" do

    should "work" do
      stub_get 'http://api.twitter.com/1/geo/reverse_geocode.json?lat=35.061161&long=-80.854568', 'geo_reverse_geocode.json'
      places = Geo.reverse_geocode(:lat => 35.061161, :long => -80.854568)
      assert_equal 4, places.size
      assert_equal 'Ballantyne West, Charlotte', places[0].full_name
      assert_equal 'Ballantyne West', places[0].name
    end

    should "be able to limit the number of results returned" do
      stub_get 'http://api.twitter.com/1/geo/reverse_geocode.json?lat=35.061161&max_results=2&long=-80.854568', 'geo_reverse_geocode_limit.json'
      places = Geo.reverse_geocode(:lat => 35.061161, :long => -80.854568, :max_results => 2)
      assert_equal 2, places.size
      assert_equal 'Ballantyne West, Charlotte', places[0].full_name
      assert_equal 'Ballantyne West', places[0].name
    end

    should "be able to lookup with granularity" do
      stub_get 'http://api.twitter.com/1/geo/reverse_geocode.json?lat=35.061161&long=-80.854568&granularity=city', 'geo_reverse_geocode_granularity.json'
      places = Geo.reverse_geocode(:lat => 35.061161, :long => -80.854568, :granularity => 'city')
      assert_equal 3, places.size
      assert_equal 'Charlotte, NC', places[0].full_name
      assert_equal 'Charlotte', places[0].name
      assert_equal 'North Carolina, US', places[1].full_name
      assert_equal 'North Carolina', places[1].name
    end

  end
end
