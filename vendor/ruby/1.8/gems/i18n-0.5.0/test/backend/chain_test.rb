require 'test_helper'

class I18nBackendChainTest < Test::Unit::TestCase
  def setup
    @first  = backend(:en => {
      :foo => 'Foo', :formats => { :short => 'short' }, :plural_1 => { :one => '%{count}' }
    })
    @second = backend(:en => {
      :bar => 'Bar', :formats => { :long => 'long' }, :plural_2 => { :one => 'one' }
    })
    @chain  = I18n.backend = I18n::Backend::Chain.new(@first, @second)
  end

  test "looks up translations from the first chained backend" do
    assert_equal 'Foo', @first.send(:translations)[:en][:foo]
    assert_equal 'Foo', I18n.t(:foo)
  end

  test "looks up translations from the second chained backend" do
    assert_equal 'Bar', @second.send(:translations)[:en][:bar]
    assert_equal 'Bar', I18n.t(:bar)
  end

  test "defaults only apply to lookups on the last backend in the chain" do
    assert_equal 'Foo', I18n.t(:foo, :default => 'Bah')
    assert_equal 'Bar', I18n.t(:bar, :default => 'Bah')
    assert_equal 'Bah', I18n.t(:bah, :default => 'Bah') # default kicks in only here
  end

  test "default" do
    assert_equal 'Fuh',  I18n.t(:default => 'Fuh')
    assert_equal 'Zero', I18n.t(:default => { :zero => 'Zero' }, :count => 0)
    assert_equal({ :zero => 'Zero' }, I18n.t(:default => { :zero => 'Zero' }))
    assert_equal 'Foo', I18n.t(:default => :foo)
  end

  test 'default is returned if translation is missing' do
    assert_equal({}, I18n.t(:'i18n.transliterate.rule', :locale => 'en', :default => {}))
  end

  test "namespace lookup collects results from all backends" do
    assert_equal({ :short => 'short', :long => 'long' }, I18n.t(:formats))
  end

  test "namespace lookup with only the first backend returning a result" do
    assert_equal({ :one => '%{count}' }, I18n.t(:plural_1))
  end

  test "pluralization still works" do
    assert_equal '1',   I18n.t(:plural_1, :count => 1)
    assert_equal 'one', I18n.t(:plural_2, :count => 1)
  end

  test "bulk lookup collects results from all backends" do
    assert_equal ['Foo', 'Bar'], I18n.t([:foo, :bar])
    assert_equal ['Foo', 'Bar', 'Bah'], I18n.t([:foo, :bar, :bah], :default => 'Bah')
    assert_equal [{ :short => 'short', :long => 'long' }, { :one => 'one' }, 'Bah'], I18n.t([:formats, :plural_2, :bah], :default => 'Bah')
  end

  protected

    def backend(translations)
      backend = I18n::Backend::Simple.new
      translations.each { |locale, data| backend.store_translations(locale, data) }
      backend
    end
end
