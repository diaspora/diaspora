# encoding: utf-8

module I18n
  module Tests
    module Procs
      test "lookup: given a translation is a proc it calls the proc with the key and interpolation values" do
        I18n.backend.store_translations(:en, :a_lambda => lambda { |*args| filter_args(*args) })
        assert_equal '[:a_lambda, {:foo=>"foo"}]', I18n.t(:a_lambda, :foo => 'foo')
      end

      test "defaults: given a default is a Proc it calls it with the key and interpolation values" do
        proc = lambda { |*args| filter_args(*args) }
        assert_equal '[nil, {:foo=>"foo"}]', I18n.t(nil, :default => proc, :foo => 'foo')
      end

      test "defaults: given a default is a key that resolves to a Proc it calls it with the key and interpolation values" do
        I18n.backend.store_translations(:en, :a_lambda => lambda { |*args| filter_args(*args) })
        assert_equal '[:a_lambda, {:foo=>"foo"}]', I18n.t(nil, :default => :a_lambda, :foo => 'foo')
        assert_equal '[:a_lambda, {:foo=>"foo"}]', I18n.t(nil, :default => [nil, :a_lambda], :foo => 'foo')
      end

      test "interpolation: given an interpolation value is a lambda it calls it with key and values before interpolating it" do
        proc = lambda { |*args| filter_args(*args) }
        assert_match %r(\[\{:foo=>#<Proc.*>\}\]), I18n.t(nil, :default => '%{foo}', :foo => proc)
      end

      test "interpolation: given a key resolves to a Proc that returns a string then interpolation still works" do
        proc = lambda { |*args| "%{foo}: " + filter_args(*args) }
        assert_equal 'foo: [nil, {:foo=>"foo"}]', I18n.t(nil, :default => proc, :foo => 'foo')
      end

      test "pluralization: given a key resolves to a Proc that returns valid data then pluralization still works" do
        proc = lambda { |*args| { :zero => 'zero', :one => 'one', :other => 'other' } }
        assert_equal 'zero',  I18n.t(:default => proc, :count => 0)
        assert_equal 'one',   I18n.t(:default => proc, :count => 1)
        assert_equal 'other', I18n.t(:default => proc, :count => 2)
      end

      test "lookup: given the option :resolve => false was passed it does not resolve proc translations" do
        I18n.backend.store_translations(:en, :a_lambda => lambda { |*args| filter_args(*args) })
        assert_equal Proc, I18n.t(:a_lambda, :resolve => false).class
      end

      test "lookup: given the option :resolve => false was passed it does not resolve proc default" do
        assert_equal Proc, I18n.t(nil, :default => lambda { |*args| filter_args(*args) }, :resolve => false).class
      end

      protected

      def filter_args(*args)
        args.map {|arg| arg.delete(:fallback) if arg.is_a?(Hash) ; arg }.inspect
      end
    end
  end
end
