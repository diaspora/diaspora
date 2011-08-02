require 'couch_potato'
require 'json/pure' unless defined? ::JSON
::CouchPotato::Config.database_name = 'couch_potato_test'

class CouchPotatoWidget
  include CouchPotato::Persistence

  property :name
  view :by_name, :key => :name


  # mimic the AR interface used in example_steps

  def self.create!(attrs = {})
    CouchPotato.database.save(self.new)
  end

  def self.count
    CouchPotato.database.view(self.by_name).size
  end
end

class CouchPotatoWidgetUsingDatabaseOne
  include CouchPotato::Persistence

  database_name = 'couch_potato_test_one'

  property :name
  view :by_name, :key => :name


  # mimic the AR interface used in example_steps

  def self.create!(attrs = {})
    CouchPotato.database.save(self.new)
  end

  def self.count
    CouchPotato.database.view(self.by_name).size
  end
end

class CouchPotatoWidgetUsingDatabaseTwo
  include CouchPotato::Persistence

  database_name = 'couch_potato_test_two'

  property :name
  view :by_name, :key => :name


  # mimic the AR interface used in example_steps

  def self.create!(attrs = {})
    CouchPotato.database.save(self.new)
  end

  def self.count
    CouchPotato.database.view(self.by_name).size
  end
end
