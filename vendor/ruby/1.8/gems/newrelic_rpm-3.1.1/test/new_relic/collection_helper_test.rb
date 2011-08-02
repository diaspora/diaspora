require File.expand_path(File.join(File.dirname(__FILE__),'..','test_helper'))
require 'ostruct'
require 'active_record_fixtures' if defined?(::ActiveRecord)

require 'new_relic/collection_helper'
class NewRelic::CollectionHelperTest < Test::Unit::TestCase

  def setup
    NewRelic::Agent.manual_start
    super
  end
  def teardown
    super
  end

  include NewRelic::CollectionHelper
  def test_string
    val = (('A'..'Z').to_a.join * 100).to_s
    assert_equal val[0...256] + "...", normalize_params(val)
  end
  def test_array
    new_array = normalize_params [ 1000 ] * 2000
    assert_equal 1024, new_array.size
    assert_equal '1000', new_array[0]
  end
  def test_boolean
    np = normalize_params(NewRelic::Control.instance.settings)
    assert_equal false, np['monitor_mode']
  end
  def test_string__singleton
    val = "This String"
    def val.hello; end
    assert_equal "This String", normalize_params(val)
    assert val.respond_to?(:hello)
    assert !normalize_params(val).respond_to?(:hello)
  end
  class MyString < String; end
  def test_kind_of_string
    s = MyString.new "This is a string"
    assert_equal "This is a string", s.to_s
    assert_equal MyString, s.class
    assert_equal String, s.to_s.class
    params = normalize_params(:val => [s])
    assert_equal String, params[:val][0].class
    assert_equal String, flatten(s).class
    assert_equal String, truncate(s, 2).class
  end
  def test_number
    np = normalize_params({ 'one' => 1.0, 'two' => '2'})
  end
  def test_nil
    np = normalize_params({ nil => 1.0, 'two' => nil})
    assert_equal "1.0", np['']
    assert_equal nil, np['two']
  end
  def test_hash
    val = ('A'..'Z').to_a.join * 100
    assert_equal Hash["ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEF..." => (("0"*256) + "...")], normalize_params({ val => '0' * 512 })
  end
  class MyHash < Hash

  end
  # Test to ensure that hash subclasses are properly converted
  def test_hash_subclass
    h = MyHash.new
    h[:mine] = 'mine'
    custom_params = { :one => {:hash => { :a => :b}, :myhash => h }}
    nh = normalize_params(custom_params)
    myhash = custom_params[:one][:myhash]
    assert_equal MyHash, myhash.class
    myhash = nh[:one][:myhash]
    assert_equal Hash, myhash.class
  end



  def test_enumerable
    e = MyEnumerable.new
    custom_params = { :one => {:hash => { :a => :b}, :myenum => e }}
    nh = normalize_params(custom_params)
    myenum = nh[:one][:myenum]
    assert_match /MyEnumerable/, myenum
  end

  def test_stringio
    # Verify StringIO works like this normally:
    s = StringIO.new "start" + ("foo bar bat " * 1000)
    val = nil
    s.each { | entry | val = entry; break }
    assert_match /^startfoo bar/, val

    # make sure stringios aren't affected by calling normalize_params:
    s = StringIO.new "start" + ("foo bar bat " * 1000)
    v = normalize_params({ :foo => s.string })
    s.each { | entry | val = entry; break }
    assert_match /^startfoo bar/, val
  end
  class MyEnumerable
    include Enumerable
    
    def each
      yield "1"
    end
  end
  
  def test_object
    assert_equal ["foo", '#<OpenStruct>'], normalize_params(['foo', OpenStruct.new('z'=>'q')])
  end

  def test_strip_backtrace
    clean_trace = strip_nr_from_backtrace(mock_backtrace)
    assert_equal(0, clean_trace.grep(/newrelic_rpm/).size,
                 "should remove all instances of new relic from backtrace but got: #{clean_trace.join("\n")}")
    assert_equal(0, clean_trace.grep(/trace/).size, 
                     "should remove trace method tags from method names but got: #{clean_trace.join("\n")}")
    assert((clean_trace.grep(/find/).size >= 3),
               "should see at least three frames with 'find' in them: \n#{clean_trace.join("\n")}")
  end

  def test_disabled_strip_backtrace
    NewRelic::Control.instance['disable_backtrace_cleanup'] = true
    clean_trace = strip_nr_from_backtrace(mock_backtrace)
    assert_equal(1, clean_trace.grep(/new_relic/).size,
            "should not remove instances of new relic from backtrace but got: #{clean_trace.join("\n")}")
    assert_equal(1, clean_trace.grep(/_trace/).size, 
                   "should not remove trace method tags from method names but got: #{clean_trace.join("\n")}")
    #       assert (clean_trace.grep(/find/).size >= 3), "should see at least three frames with 'find' in them (#{e}): \n#{clean_trace.join("\n")}"
    NewRelic::Control.instance['disable_backtrace_cleanup'] = false
  end
  
  private 
  def mock_backtrace
    [
   %q{/home/app/gems/activerecord-2.3.12/lib/active_record/base.rb:1620:in `find_one_without_trace'}, 
   %q{/home/app/gems/activerecord-2.3.12/lib/active_record/base.rb:1620:in `find_one'}, 
   %q{/home/app/gems/activerecord-2.3.12/lib/active_record/base.rb:1603:in `find_from_ids'}, 
   %q{./test/new_relic/collection_helper_test.rb:112:in `test_strip_stackdump'}, 
   %q{/home/app/gems/mocha-0.9.8/lib/mocha/integration/test_unit/ruby_version_186_and_above.rb:19:in `__send__'}, 
   %q{/home/app/gems/mocha-0.9.8/lib/mocha/integration/test_unit/ruby_version_186_and_above.rb:19:in `run'}, 
   %q{/home/app/test/unit/testsuite.rb:34:in `run'}, 
   %q{/home/app/test/unit/testsuite.rb:33:in `each'}, 
   %q{/home/app/test/unit/testsuite.rb:33:in `run'}, 
   %q{/home/app/test/unit/testsuite.rb:34:in `run'}, 
   %q{/home/app/test/unit/testsuite.rb:33:in `each'}, 
   %q{/home/app/test/unit/testsuite.rb:33:in `run'}, 
   %q{/home/app/test/unit/ui/testrunnermediator.rb:46:in `run_suite'}
   ]
  end
end
