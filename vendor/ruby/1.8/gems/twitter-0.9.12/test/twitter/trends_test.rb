require 'test_helper'

class TrendsTest < Test::Unit::TestCase
  include Twitter

  context "Getting current trends" do
    should "work" do
      stub_get 'http://api.twitter.com/1/trends/current.json', 'trends_current.json'
      trends = Trends.current
      assert_equal 10, trends.size
      assert_equal '#musicmonday', trends[0].name
      assert_equal '#musicmonday', trends[0].query
      assert_equal '#newdivide', trends[1].name
      assert_equal '#newdivide', trends[1].query
    end

    should "be able to exclude hashtags" do
      stub_get 'http://api.twitter.com/1/trends/current.json?exclude=hashtags', 'trends_current_exclude.json'
      trends = Trends.current(:exclude => 'hashtags')
      assert_equal 10, trends.size
      assert_equal 'New Divide', trends[0].name
      assert_equal %Q(\"New Divide\"), trends[0].query
      assert_equal 'Star Trek', trends[1].name
      assert_equal %Q(\"Star Trek\"), trends[1].query
    end
  end

  context "Getting daily trends" do
    should "work" do
      stub_get 'http://api.twitter.com/1/trends/daily.json?', 'trends_daily.json'
      trends = Trends.daily
      assert_equal 480, trends.size
      assert_equal '#3turnoffwords', trends[0].name
      assert_equal '#3turnoffwords', trends[0].query
    end

    should "be able to exclude hastags" do
      stub_get 'http://api.twitter.com/1/trends/daily.json?exclude=hashtags', 'trends_daily_exclude.json'
      trends = Trends.daily(:exclude => 'hashtags')
      assert_equal 480, trends.size
      assert_equal 'Kobe', trends[0].name
      assert_equal %Q(Kobe), trends[0].query
    end

    should "be able to get for specific date (with date string)" do
      stub_get 'http://api.twitter.com/1/trends/daily.json?date=2009-05-01', 'trends_daily_date.json'
      trends = Trends.daily(:date => '2009-05-01')
      assert_equal 440, trends.size
      assert_equal 'Swine Flu', trends[0].name
      assert_equal %Q(\"Swine Flu\" OR Flu), trends[0].query
    end

    should "be able to get for specific date (with date object)" do
      stub_get 'http://api.twitter.com/1/trends/daily.json?date=2009-05-01', 'trends_daily_date.json'
      trends = Trends.daily(:date => Date.new(2009, 5, 1))
      assert_equal 440, trends.size
      assert_equal 'Swine Flu', trends[0].name
      assert_equal %Q(\"Swine Flu\" OR Flu), trends[0].query
    end
  end

  context "Getting weekly trends" do
    should "work" do
      stub_get 'http://api.twitter.com/1/trends/weekly.json?', 'trends_weekly.json'
      trends = Trends.weekly
      assert_equal 210, trends.size
      assert_equal "Grey's Anatomy", trends[0].name
      assert_equal %Q(\"Grey's Anatomy\"), trends[0].query
    end

    should "be able to exclude hastags" do
      stub_get 'http://api.twitter.com/1/trends/weekly.json?exclude=hashtags', 'trends_weekly_exclude.json'
      trends = Trends.weekly(:exclude => 'hashtags')
      assert_equal 210, trends.size
      assert_equal "Grey's Anatomy", trends[0].name
      assert_equal %Q(\"Grey's Anatomy\"), trends[0].query
    end

    should "be able to get for specific date (with date string)" do
      stub_get 'http://api.twitter.com/1/trends/weekly.json?date=2009-05-01', 'trends_weekly_date.json'
      trends = Trends.weekly(:date => '2009-05-01')
      assert_equal 210, trends.size
      assert_equal 'Swine Flu', trends[0].name
      assert_equal %Q(\"Swine Flu\"), trends[0].query
    end

    should "be able to get for specific date (with date object)" do
      stub_get 'http://api.twitter.com/1/trends/weekly.json?date=2009-05-01', 'trends_weekly_date.json'
      trends = Trends.weekly(:date => Date.new(2009, 5, 1))
      assert_equal 210, trends.size
      assert_equal 'Swine Flu', trends[0].name
      assert_equal %Q(\"Swine Flu\"), trends[0].query
    end
  end

  context "Getting local trends" do

    should "return a list of available locations" do
      stub_get 'http://api.twitter.com/1/trends/available.json?lat=33.237593417&lng=-96.960559033', 'trends_available.json'
      locations = Trends.available(:lat => 33.237593417, :lng => -96.960559033)
      assert_equal 'Ireland', locations.first.country
      assert_equal 12, locations.first.placeType.code
    end

    should "return a list of trends for a given location" do
      stub_get 'http://api.twitter.com/1/trends/2487956.json', 'trends_location.json'
      trends = Trends.for_location(2487956).first.trends
      assert_equal 'Gmail', trends.last.name
    end
  end

end
