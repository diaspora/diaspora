require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../test_credentials.rb'

class TestSdb < Test::Unit::TestCase
  
  DOMAIN_NAME = 'right_sdb_awesome_test_domain'
  DASH_DOMAIN_NAME = 'right_sdb-awesome_test_domain'
  
  class Client < Aws::ActiveSdb::Base
    set_domain_name DOMAIN_NAME
  end
  class DashClient < RightAws::ActiveSdb::Base
    set_domain_name DASH_DOMAIN_NAME
  end

  def setup
      TestCredentials.get_credentials
    STDOUT.sync  = true
    @clients = [ 
      { 'name' => 'Bush',     'country' => 'USA',    'gender' => 'male',   'expiration' => '2009', 'post' => 'president' },
      { 'name' => 'Putin',    'country' => 'Russia', 'gender' => 'male',   'expiration' => '2008', 'post' => 'president' },
      { 'name' => 'Medvedev', 'country' => 'Russia', 'gender' => 'male',   'expiration' => '2012', 'post' => 'president' },
      { 'name' => 'Mary',     'country' => 'USA',    'gender' => 'female', 'hobby' => ['patchwork', 'bundle jumping'] },
      { 'name' => 'Sandy',    'country' => 'Russia', 'gender' => 'female', 'hobby' => ['flowers', 'cats', 'cooking'] },
      { 'name' => 'Mary',     'country' => 'Russia', 'gender' => 'female', 'hobby' => ['flowers', 'cats', 'cooking'] } ]
    Aws::ActiveSdb.establish_connection(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key)
  end

  SDB_DELAY = 3
  
  def wait(delay, msg='')
    print "     waiting #{delay} seconds: #{msg}"
    while delay>0 do
      delay -= 1
      print '.'
      sleep 1
    end
    puts
  end

  #---------------------------
  # Aws::SdbInterface
  #---------------------------

  def test_00_delete_domain
    assert Aws::ActiveSdb.delete_domain(DOMAIN_NAME)
    wait SDB_DELAY, 'test 00: after domain deletion'
  end
  
  def test_01_create_domain
    # check that domain does not exist
    assert !Aws::ActiveSdb.domains.include?(DOMAIN_NAME)
    # create domain
    assert Client.create_domain
    wait SDB_DELAY, 'test 01: after domain creation'
    # check that we have received new domain from Amazin
    assert Aws::ActiveSdb.domains.include?(DOMAIN_NAME)
  end

  def test_02_create_items
    # check that DB is empty
    clients = Client.find(:all)
    assert clients.blank?
    # put some clients there
    @clients.each do |client|
      Client.create client
    end
    wait SDB_DELAY, 'test 02: after clients creation'
    # check that DB has all the clients we just putted
    clients = Client.find(:all)
    assert_equal @clients.size, clients.size
  end
  
  def test_03_create_and_save_new_item
    # get the db
    old_clients = Client.find(:all)
    # create new client
    new_client = Client.new('country' => 'unknown', 'dummy' => 'yes')
    wait SDB_DELAY, 'test 03: after in-memory client creation'
    # get the db and ensure we created the client in-memory only
    assert_equal old_clients.size, Client.find(:all).size
    # put the client to DB
    new_client.save
    wait SDB_DELAY, 'test 03: after in-memory client saving'
    # get all db again and compare to original list
    assert_equal old_clients.size+1, Client.find(:all).size
  end

  def test_04_find_all
    # retrieve all the DB, make sure all are in place
    clients = Client.find(:all)
    ids = clients.map{|client| client.id }[0..1]
    assert_equal @clients.size + 1, clients.size
    # retrieve all presidents (must find: Bush, Putin, Medvedev)
    assert_equal 3, Client.find(:all, :conditions => ["post=?",'president']).size
    # retrieve all russian presidents (must find: Putin, Medvedev)
    assert_equal 2, Client.find(:all, :conditions => ["post=? and country=?",'president', 'Russia']).size
    # retrieve all russian presidents and all women (must find: Putin, Medvedev, 2 Maries and Sandy)
    assert_equal 5, Client.find(:all, :conditions => ["post=? and country=? or gender=?",'president', 'Russia','female']).size
    # find all rissian presidents Bushes
    assert_equal 0, Client.find(:all, :conditions => ["post=? and country=? and name=?",'president', 'Russia','Bush']).size
    # --- find by ids
    # must find 1 rec (by rec id) and return it
    assert_equal ids.first, Client.find(ids.first).id
    # must find 1 rec (by one item array) and return an array
    assert_equal ids.first, Client.find([ids.first]).first.id
    # must find 2 recs (by a list of comma separated ids) and return an array
    assert_equal ids.size, Client.find(*ids).size
    # must find 2 recs (by an array of ids) and return an array
    assert_equal ids.size, Client.find(ids).size
    ids << 'dummy_id'
    # must raise an error when getting unexistent record
    assert_raise(Aws::ActiveSdb::ActiveSdbError) do
      Client.find(ids)
    end
    # find one record by unknown id
    assert_raise(Aws::ActiveSdb::ActiveSdbError) do
      Client.find('dummy_id')
    end
  end

  def test_04b_find_all_dashed
    # retrieve all the DB, make sure all are in place
    clients = DashClient.find(:all)
    ids = clients.map{|client| client.id }[0..1]
    assert_equal @clients.size + 1, clients.size
    # retrieve all presidents (must find: Bush, Putin, Medvedev)
    assert_equal 3, DashedClient.find(:all, :conditions => ["[?=?]",'post','president']).size
    # retrieve all russian presidents (must find: Putin, Medvedev)
    assert_equal 2, DashedClient.find(:all, :conditions => ["['post'=?] intersection ['country'=?]",'president', 'Russia']).size
    # retrieve all russian presidents and all women (must find: Putin, Medvedev, 2 Maries and Sandy)
    assert_equal 5, DashedClient.find(:all, :conditions => ["['post'=?] intersection ['country'=?] union ['gender'=?]",'president', 'Russia','female']).size
    # find all rissian presidents Bushes
    assert_equal 0, DashedClient.find(:all, :conditions => ["['post'=?] intersection ['country'=?] intersection ['name'=?]",'president', 'Russia','Bush']).size
    # --- find by ids
    # must find 1 rec (by rec id) and return it
    assert_equal ids.first, DashedClient.find(ids.first).id
    # must find 1 rec (by one item array) and return an array
    assert_equal ids.first, DashedClient.find([ids.first]).first.id
    # must find 2 recs (by a list of comma separated ids) and return an array
    assert_equal ids.size, DashedClient.find(*ids).size
    # must find 2 recs (by an array of ids) and return an array
    assert_equal ids.size, DashedClient.find(ids).size
    ids << 'dummy_id'
    # must raise an error when getting unexistent record
    assert_raise(RightAws::ActiveSdb::ActiveSdbError) do 
      DashedClient.find(ids)
    end
    # find one record by unknown id
    assert_raise(RightAws::ActiveSdb::ActiveSdbError) do
      DashedClient.find('dummy_id')
    end
  end

  def test_05_find_first
    # find any record
    assert Client.find(:first)
    # find any president
    assert Client.find(:first, :conditions => ["post=? and country=?",'president','Russia'])
    # find any rissian president
    assert_nil Client.find(:first, :conditions => ["post=? and country=?",'president','Rwanda'])
    # find any unexistent record
    assert Client.find(:first, :conditions => ["?=?",'post','president'])
  end

  def test_06_find_all_by_helpers
    # find all Bushes
    assert_equal 1, Client.find_all_by_name('Bush').size
    # find all russian presidents
    assert_equal 2, Client.find_all_by_post_and_country('president','Russia').size
    # find all women in USA that love flowers
    assert_equal 2, Client.find_all_by_gender_and_country_and_hobby('female','Russia','flowers').size
    # order and auto_load:
    clients = Client.find_all_by_post('president', :order => 'name', :auto_load => true)
    assert_equal [['Bush'], ['Medvedev'], ['Putin']], clients.map{|c| c['name']}
    clients = Client.find_all_by_post('president', :order => 'name desc', :auto_load => true)
    assert_equal [['Putin'], ['Medvedev'], ['Bush']], clients.map{|c| c['name']}
  end
  
  def test_07_find_by_helpers
    # find mr Bush
    assert Client.find_by_name('Bush')
    # find any russian president
    assert Client.find_by_post_and_country('president','Russia')
    # find Mary in Russia that loves flowers
    # order and auto_load:
    assert_equal ['Bush'],  Client.find_by_post('president', :order => 'name',      :auto_load => true)['name']
    assert_equal ['Putin'], Client.find_by_post('president', :order => 'name desc', :auto_load => true)['name']
  end

  def test_08_reload
    putin = Client.find_by_name('Putin')
    # attributes must be empty until reload (except 'id' field)
    assert_nil putin['name']
    assert_nil putin['country']
    assert_nil putin['gender']
    assert_nil putin['expiration']
    assert_nil putin['post']
    # reloaded attributes must have 5 items + id
    putin.reload
    assert_equal 6, putin.attributes.size
    # check all attributes
    assert_equal ['Putin'],     putin['name']
    assert_equal ['Russia'],    putin['country']
    assert_equal ['male'],      putin['gender']
    assert_equal ['2008'],      putin['expiration']
    assert_equal ['president'], putin['post']
  end

  def test_09_select
    # select all records
    assert_equal 7, Client.select(:all).size
    # LIMIT
    # 1 record
    assert Client.select(:first).is_a?(Client)
    # select 2 recs
    assert_equal 2, Client.select(:all, :limit => 2).size
    # ORDER
    # select all recs ordered by 'expration' (must find only recs where 'expration' attribute presents)
    result = Client.select(:all, :order => 'expiration')
    assert_equal 3, result.size
    assert_equal ['2008', '2009', '2012'], result.map{ |c| c['expiration'] }.flatten
    # desc order
    result = Client.select(:all, :order => 'expiration desc')
    assert_equal ['2012', '2009', '2008'], result.map{ |c| c['expiration'] }.flatten
    # CONDITIONS
    result = Client.select(:all, :conditions => ["expiration >= ?", 2009], :order => 'name')
    assert_equal ['Bush', 'Medvedev'], result.map{ |c| c['name'] }.flatten
    result = Client.select(:all, :conditions => "hobby='flowers' AND gender='female'", :order => 'name')
    assert_equal ['Mary', 'Sandy'], result.map{ |c| c['name'] }.flatten
    # SELECT
    result = Client.select(:all, :select => 'hobby', :conditions => "gender IS NOT NULL", :order => 'name')
    hobbies = result.map{|c| c['hobby']}
    # must return all recs
    assert_equal 6, result.size
    # but anly 3 of them have this field set
    assert_equal 3, hobbies.compact.size
  end

  def test_10_select_by
    assert_equal 2, Client.select_all_by_hobby('flowers').size
    assert_equal 2, Client.select_all_by_hobby_and_country('flowers', 'Russia').size
    assert_equal ['Putin'], Client.select_by_post_and_expiration('president','2008')['name']
  end
  
  def test_11_save_and_put
    putin = Client.find_by_name('Putin')
    putin.reload
    putin['hobby'] = 'ski'
    # SAVE method (replace values)
    putin.save
    wait SDB_DELAY, 'test 09: after saving'
    # check that DB was updated with 'ski'
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert ['ski'], new_putin['hobby']
    # replace hobby
    putin['hobby'] = 'dogs'
    putin.save
    wait SDB_DELAY, 'test 09: after saving'
    # check that 'ski' in DB was replaced by 'dogs'
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert ['dogs'], new_putin['hobby']
    # PUT method (add values)
    putin['hobby'] = 'ski'
    putin.put
    wait SDB_DELAY, 'test 09: after putting'
    # check that 'ski' was added to 'dogs'
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert ['dogs', 'ski'], new_putin['hobby'].sort
  end

  def test_12_save_and_put_attributes
    putin = Client.find_by_name('Putin')
    putin.reload
    # SAVE method (replace values)
    putin.save_attributes('language' => 'russian')
    wait SDB_DELAY, 'test 10: after save_attributes'
    # check that DB was updated with 'ski'
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert ['russian'], new_putin['language']
    # replace 'russian' by 'german'
    putin.save_attributes('language' => 'german')
    wait SDB_DELAY, 'test 10: after save_attributes'
    # check that 'russian' in DB was replaced by 'german'
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert ['german'], new_putin['language']
    # PUT method (add values)
    putin.put_attributes('language' => ['russian', 'english'])
    wait SDB_DELAY, 'test 10: after put_attributes'
    # now Putin must know all the languages
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert ['english', 'german', 'russian'], new_putin['language'].sort
  end
  
  def test_13_delete
    putin = Client.find_by_name('Putin')
    putin.reload
    # --- delete_values
    # remove an unknown attribute
    # should return an empty hash
    assert_equal( {}, putin.delete_values('undefined_attribute' => 'ohoho'))
    # remove 2 languages
    lang_hash = {'language' => ['english', 'german']}
    assert_equal lang_hash, putin.delete_values(lang_hash)
    wait SDB_DELAY, 'test 11: after put_attributes'
    # now Putin must know only russian lang
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert ['russian'], new_putin['language'].sort
    # --- delete_attributes
    putin.delete_attributes('language', 'hobby')
    wait SDB_DELAY, 'test 11: after delete_attributes'
    # trash hoddy and langs
    new_putin = Client.find_by_name('Putin')
    new_putin.reload
    assert_nil new_putin['language']
    assert_nil new_putin['hobby']
    # --- delete item
    putin.delete
    wait SDB_DELAY, 'test 11: after delete item'
    assert_nil Client.find_by_name('Putin')
  end
  
  def test_14_delete_domain
    assert Client.delete_domain
    wait SDB_DELAY, 'test 12: after delete domain'
    assert_raise(Aws::AwsError) do
      Client.find :all 
    end
  end
    
end