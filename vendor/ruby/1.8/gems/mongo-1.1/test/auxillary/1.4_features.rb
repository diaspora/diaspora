$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongo'
require 'test/unit'
require './test/test_helper'

# Demonstrate features in MongoDB 1.4
class Features14Test < Test::Unit::TestCase

  context "MongoDB 1.4" do
    setup do
      @con = Mongo::Connection.new
      @db  = @con['mongo-ruby-test']
      @col = @db['new-features']
    end

    teardown do
      @col.drop
    end

    context "new query operators: " do

      context "$elemMatch: " do
        setup do
          @col.save({:user => 'bob', :updates => [{:date => Time.now.utc, :body => 'skiing', :n => 1},
                                                  {:date => Time.now.utc, :body => 'biking', :n => 2}]})

          @col.save({:user => 'joe', :updates => [{:date => Time.now.utc, :body => 'skiing', :n => 2},
                                                  {:date => Time.now.utc, :body => 'biking', :n => 10}]})
        end

        should "match a document with a matching object element in an array" do
          doc = @col.find_one({"updates" => {"$elemMatch" => {"body" => "skiing", "n" => 2}}})
          assert_equal 'joe', doc['user']
        end

        should "$elemMatch with a conditional operator" do
          doc1 = @col.find_one({"updates" => {"$elemMatch" => {"body" => "biking", "n" => {"$gt" => 5}}}})
          assert_equal 'joe', doc1['user']
        end

        should "note the difference between $elemMatch and a traditional match" do
          doc = @col.find({"updates.body" => "skiing", "updates.n" => 2}).to_a
          assert_equal 2, doc.size
        end
      end

      context "$all with regexes" do
        setup do
          @col.save({:n => 1, :a => 'whale'})
          @col.save({:n => 2, :a => 'snake'})
        end

        should "match multiple regexes" do
          doc = @col.find({:a => {'$all' => [/ha/, /le/]}}).to_a
          assert_equal 1, doc.size
          assert_equal 1, doc.first['n']
        end

        should "not match if not every regex matches" do
          doc = @col.find({:a => {'$all' => [/ha/, /sn/]}}).to_a
          assert_equal 0, doc.size
        end
      end

      context "the $not operator" do
        setup do
          @col.save({:a => ['x']})
          @col.save({:a => ['x', 'y']})
          @col.save({:a => ['x', 'y', 'z']})
        end

        should "negate a standard operator" do
          results = @col.find({:a => {'$not' => {'$size' => 2}}}).to_a
          assert_equal 2, results.size
          results = results.map {|r| r['a']}
          assert_equal ['x'], results.sort.first
          assert_equal ['x', 'y', 'z'], results.sort.last
        end
      end
    end

    context "new update operators: " do

      context "$addToSet (pushing a unique value)" do
        setup do
          @col.save({:username => 'bob', :interests => ['skiing', 'guitar']})
        end

        should "add an item to a set uniquely ($addToSet)" do
          @col.update({:username => 'bob'}, {'$addToSet' => {'interests' => 'skiing'}})
          @col.update({:username => 'bob'}, {'$addToSet' => {'interests' => 'kayaking'}})
          document = @col.find_one({:username => 'bob'})
          assert_equal ['guitar', 'kayaking', 'skiing'], document['interests'].sort
        end

        should "add an array of items uniquely ($addToSet with $each)" do
          @col.update({:username => 'bob'}, {'$addToSet' => {'interests' => {'$each' => ['skiing', 'kayaking', 'biking']}}})
          document = @col.find_one({:username => 'bob'})
          assert_equal ['biking', 'guitar', 'kayaking', 'skiing'], document['interests'].sort
        end
      end

      context "the positional operator ($)" do
        setup do
          @id1 = @col.insert({:text => 'hello',
                             :comments => [{'by'   => 'bob',
                                            'text' => 'lol!'},
                                           {'by'   => 'susie',
                                            'text' => 'bye bye!'}]})
          @id2 = @col.insert({:text => 'goodbye',
                            :comments => [{'by'   => 'bob',
                                           'text' => 'au revoir'},
                                          {'by'   => 'susie',
                                           'text' => 'bye bye!'}]})
        end

        should "update a matching array item" do
          @col.update({"_id" => @id1, "comments.by" => 'bob'}, {'$set' => {'comments.$.text' => 'lmao!'}}, :multi => true)
          result = @col.find_one({"_id" => @id1})
          assert_equal 'lmao!', result['comments'][0]['text']
        end
      end
    end

    context "Geoindexing" do
      setup do
        @places = @db['places']
        @places.create_index([['loc', Mongo::GEO2D]])

        @empire_state = ([40.748371, -73.985031])
        @jfk = ([40.643711, -73.790009])

        @places.insert({'name' => 'Empire State Building', 'loc' => ([40.748371, -73.985031])})
        @places.insert({'name' => 'Flatiron Building', 'loc' => ([40.741581, -73.987549])})
        @places.insert({'name' => 'Grand Central', 'loc' => ([40.751678, -73.976562])})
        @places.insert({'name' => 'Columbia University', 'loc' => ([40.808922, -73.961617])})
        @places.insert({'name' => 'NYSE', 'loc' => ([40.71455, -74.007124])})
        @places.insert({'name' => 'JFK', 'loc' => ([40.643711, -73.790009])})
      end

      teardown do
        @places.drop
      end

      should "find the nearest addresses" do
        results = @places.find({'loc' => {'$near' => @empire_state}}).limit(2).to_a
        assert_equal 2, results.size
        assert_equal 'Empire State Building', results[0]['name']
        assert_equal 'Flatiron Building', results[1]['name']
      end

      should "use geoNear command to return distances from a point" do
        cmd = BSON::OrderedHash.new
        cmd['geoNear'] = 'places'
        cmd['near']    = @empire_state
        cmd['num']     = 6
        r = @db.command(cmd)

        assert_equal 6, r['results'].length
        r['results'].each do |result|
          puts result.inspect
        end
      end
    end
  end
end
