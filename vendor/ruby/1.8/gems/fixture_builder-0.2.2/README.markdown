FixtureBuilder
==============

Based on the code from fixture_scenarios, by Chris Wanstrath. Allows you to build file fixtures from an object mother factory.

Installing
==========

 1. Install as a plugin or gem:  `gem install fixture_builder`
 1. Create a file which configures and declares your fixtures (see below for example)
 1. Require the above file in your `spec_helper.rb` or `test_helper.rb`


Example
=======

When using an object mother such as factory_girl it can be setup like the following:
    
    # I usually put this file in spec/support/fixture_builder.rb
    FixtureBuilder.configure do |fbuilder|
      # rebuild fixtures automatically when these files change:
      fbuilder.files_to_check += Dir["spec/factories/*.rb", "spec/support/fixture_builder.rb"]
      
      # now declare objects
      fbuilder.factory do
        david = Factory(:user, :unique_name => "david")
        ipod = Factory(:product, :name => "iPod")
        Factory(:purchase, :user => david, :product => ipod)
      end
    end

The block passed to the factory method initiates the creation of the fixture files.  Before yielding to the block, FixtureBuilder cleans out the test database completely.  When the block finishes, it dumps the state of the database into fixtures, like this:

    # users.yml
    david: 
      created_at: 2010-09-18 17:21:23.926511 Z
      unique_name: david
      id: 1
      
    # products.yml
    i_pod:
      name: iPod
      id: 1
      
    # purchases.yml
    purchase_001:
      product_id: 1
      user_id: 1

FixtureBuilder guesses about how to name fixtures based on a prioritized list of attribute names.  You can also hint at a name or manually name an object.  Both of the following lines would work to rename `purchase_001` to `davids_ipod`:

    fbuilder.name(:davids_ipod, Factory(:purchase, :user => david, :product => ipod))
    @davids_ipod = Factory(:purchase, :user => david, :product => ipod)

There are also additional configuration options that can be changed to override the defaults:

 * files_to_check: array of filenames that when changed cause fixtures to be rebuilt
 * fixture_builder_file: the pathname of the file used to store file changes.
 * record_name_fields: array of field names to use as a fixture's name prefix, it will use the first matching field it finds
 * skip_tables: array of table names to skip building fixtures
 * select_sql: sql string to use for select
 * delete_sql: sql string to use for deletes

By default these are set as:

 * files_to_check: %w{ db/schema.rb }
 * fixture_builder_file: RAILS_ROOT/tmp/fixture_builder.yml
 * record_name_fields: %w{ schema_migrations }
 * skip_tables: %w{ schema_migrations }
 * select_sql: SELECT * FROM %s
 * delete_sql: DELETE FROM %s

Sequence Collisions
===================

One problem with generating your fixtures is that sequences can collide.  When the fixtures are generated only as needed, sometimes the process that generates the fixtures will be different than the process that runs the tests.  This results in collisions when you still use factories in your tests.  Here's a solution for FactoryGirl which resets sequences numbers to 1000 (to avoid conflicts with fixture data which should e sequenced < 1000) before the tests run:

    FixtureBuilder.configure do |fbuilder|
      ...
    end
    
    # Have factory girl generate non-colliding sequences starting at 1000 for data created after the fixtures 
    Factory.sequences.each do |name, seq|
      seq.instance_variable_set(:@value, 1000)
    end



Copyright (c) 2009 Ryan Dy & David Stevenson, released under the MIT license
