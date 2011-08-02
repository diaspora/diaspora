require File.expand_path(File.join(File.dirname(__FILE__),'..', 'test_helper'))
class NewRelic::VersionNumberTest < Test::Unit::TestCase

  def test_comparison__first
    versions = %w[1.0.0 0.1.0 0.0.1 10.0.1 1.10.0].map {|s| NewRelic::VersionNumber.new s }
    assert_equal %w[0.0.1 0.1.0 1.0.0 1.10.0 10.0.1], versions.sort.map(&:to_s)
    v0 = NewRelic::VersionNumber.new '1.2.3'
    v1 = NewRelic::VersionNumber.new '1.2.2'
    v3 = NewRelic::VersionNumber.new '1.2.2'
    assert v0 > v1
    assert v1 == v1
    assert v1 == v3
  end
  def test_comparison__second
    v0 = NewRelic::VersionNumber.new '1.2.0'
    v1 = NewRelic::VersionNumber.new '2.2.2'
    v3 = NewRelic::VersionNumber.new '1.1.2'
    assert v0 < v1
    assert v1 > v3
    assert v3 < v0
  end
  def test_bug
    v0 = NewRelic::VersionNumber.new '2.8.999'
    v1 = NewRelic::VersionNumber.new '2.9.10'
    assert v1 > v0
    assert v0 <= v1
  end
  def test_long_version
    v0 = NewRelic::VersionNumber.new '1.2.3.4'
    v1 = NewRelic::VersionNumber.new '1.2.3.3'
    v3 = NewRelic::VersionNumber.new '1.3'
    assert v0 > v1
    assert v0 < '1.2.3.5'
    assert ! (v0 < '1.2.3.4')
    assert v3 > v0
  end
  def test_sort
    values = %w[1.1.1
                1.1.99
                1.1.999
                2.0.6
                2.6.5
                2.7
                2.7.1
                2.7.2
                2.7.2.0
                3
                999]
    assert_equal values, values.map{|v| NewRelic::VersionNumber.new v}.sort.map(&:to_s)
  end
  def test_prerelease
    v0 = NewRelic::VersionNumber.new '1.2.0.beta'
    assert_equal [1,2,0,'beta'], v0.parts
    assert v0 > '1.1.9.0'
    assert v0 > '1.1.9.alpha'
    assert v0 > '1.2.0.alpha'
    assert v0 == '1.2.0.beta'
    assert v0 < '1.2.1'
    assert v0 < '1.2.0'
    assert v0 < '1.2.0.c'
    assert v0 < '1.2.0.0'

  end
  def test_compare_string
    v0 = NewRelic::VersionNumber.new '1.2.0'
    v1 = NewRelic::VersionNumber.new '2.2.2'
    v3 = NewRelic::VersionNumber.new '1.1.2'
    assert v0 < '2.2.2'
    assert v1 > '1.1.2'
    assert v3 < '1.2.0'
    assert v0 == '1.2.0'
  end
  def test_4_numbers
    v0 = NewRelic::VersionNumber.new '1.2.0'
    v1 = NewRelic::VersionNumber.new '1.2.0.1'
    v2 = NewRelic::VersionNumber.new '1.2.1.0'
    v3 = NewRelic::VersionNumber.new '1.2.1.1'
    assert v0 < v1
    assert v1 < v2
    assert v2 < v3
    assert v0 < v3
    assert v0 < '1.2.0.1'
    assert v0 > '1.1.0.1'
  end
  def test_string
    assert_equal '1.2.0', NewRelic::VersionNumber.new('1.2.0').to_s
    assert_equal '1.2', NewRelic::VersionNumber.new('1.2').to_s
  end
end
