require 'will_paginate/finders/active_record'
require 'finders/activerecord_test_connector'
ActiverecordTestConnector.setup

# load all fixtures
Fixtures.create_fixtures(ActiverecordTestConnector::FIXTURES_PATH, ActiveRecord::Base.connection.tables)

ActiverecordTestConnector.show_sql