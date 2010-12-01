# -*- encoding: utf-8 -*-

require File.expand_path('../test_helper', __FILE__)

class TestOauth < Test::Unit::TestCase

  def test_parameter_escaping_kcode_invariant
    ruby19 = RUBY_VERSION =~ /^1\.9/
    old = $KCODE if !ruby19
    begin
      %w(n N e E s S u U).each do |kcode|
        $KCODE = kcode if !ruby19
        assert_equal '%E3%81%82', OAuth::Helper.escape('あ'),
                      "Failed to correctly escape Japanese under $KCODE = #{kcode}"
        assert_equal '%C3%A9', OAuth::Helper.escape('é'),
                      "Failed to correctly escape e+acute under $KCODE = #{kcode}"
      end
    ensure
      $KCODE = old if !ruby19
    end
  end
end
