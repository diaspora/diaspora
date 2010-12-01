#!/usr/bin/env ruby

require 'test/unit'
require 'rake'
require 'test/rake_test_setup'

######################################################################
class TestAnEmptyInvocationChain < Test::Unit::TestCase
  include TestMethods

  def setup
    @empty = Rake::InvocationChain::EMPTY
  end

  def test_should_be_able_to_add_members
    assert_nothing_raised do
      @empty.append("A")
    end
  end

  def test_to_s
    assert_equal "TOP", @empty.to_s
  end
end

######################################################################
class TestAnInvocationChainWithOneMember < Test::Unit::TestCase
  include TestMethods

  def setup
    @empty = Rake::InvocationChain::EMPTY
    @first_member = "A"
    @chain = @empty.append(@first_member)
  end

  def test_should_report_first_member_as_a_member
    assert @chain.member?(@first_member)
  end

  def test_should_fail_when_adding_original_member
    ex = assert_exception RuntimeError do
      @chain.append(@first_member)
    end
    assert_match(/circular +dependency/i, ex.message)
    assert_match(/A.*=>.*A/, ex.message)
  end

  def test_to_s
    assert_equal "TOP => A", @chain.to_s
  end

end

######################################################################
class TestAnInvocationChainWithMultipleMember < Test::Unit::TestCase
  include TestMethods

  def setup
    @first_member = "A"
    @second_member = "B"
    ch = Rake::InvocationChain::EMPTY.append(@first_member)
    @chain = ch.append(@second_member)
  end

  def test_should_report_first_member_as_a_member
    assert @chain.member?(@first_member)
  end

  def test_should_report_second_member_as_a_member
    assert @chain.member?(@second_member)
  end

  def test_should_fail_when_adding_original_member
    ex = assert_exception RuntimeError do
      @chain.append(@first_member)
    end
    assert_match(/A.*=>.*B.*=>.*A/, ex.message)
  end
end


