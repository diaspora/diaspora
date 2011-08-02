##
## $Rev: 1 $
## $Release: 1.0.0 $
## copyright(c) 2006 kuwata-lab.com all rights reserved.
##

testdir = File.dirname(File.expand_path(__FILE__))
libdir  = File.dirname(testdir) + "/lib"
$: << libdir


require 'test/unit'
require 'abstract'


class Foo
  abstract_method "arg1, arg2=''", :m1, :m2, :m3
end


class Bar
  def m1(arg1, arg2='')
    not_implemented
  end
end



class AbstractTest < Test::Unit::TestCase


  def _test(obj)
    assert_raise(NotImplementedError) do
      begin
        obj = Foo.new
        obj.m1 'a'
      rescue => ex
        linenum = (ex.backtrace[0] =~ /:(\d+)/) && $1
        raise ex
      end
    end
  end


  def test_abstract_method1
    obj = Foo.new
    assert_raise(NotImplementedError) { obj.m1 'a' }
    assert_raise(NotImplementedError) { obj.m2 'a', 'b' }
  end


  def test_abstract_method2
    begin
      obj = Foo.new
      linenum = __LINE__; obj.m1 'a'
    rescue NotImplementedError => ex
      actual_linenum = (ex.backtrace[0] =~ /:(\d+)/) && $1.to_i
    end
    assert_equal linenum, actual_linenum
  end


  def test_not_implemented1
    obj = Bar.new
    assert_raise(NotImplementedError) { obj.m1 123 }
  end


  def test_not_implemented2
    begin
      obj = Bar.new
      linenum = __LINE__; obj.m1 'a'
    rescue NotImplementedError => ex
      actual_linenum = (ex.backtrace[0] =~ /:(\d+)/) && $1.to_i
    end
    assert_equal linenum, actual_linenum
  end


  def test_not_implemented3
    begin
      obj = Bar.new
      obj.not_implemented
    rescue Exception => ex
      assert_instance_of(NoMethodError, ex)
      assert_match(/private method/, ex.message)
    end
  end


end
