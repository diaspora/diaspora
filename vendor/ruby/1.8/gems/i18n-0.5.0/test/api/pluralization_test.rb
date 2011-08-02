require 'test_helper'

class I18nPluralizationApiTest < Test::Unit::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Pluralization
  end

  def setup
    I18n.backend = Backend.new
    super
  end

  include I18n::Tests::Basics
  include I18n::Tests::Defaults
  include I18n::Tests::Interpolation
  include I18n::Tests::Link
  include I18n::Tests::Lookup
  include I18n::Tests::Pluralization
  include I18n::Tests::Procs
  include I18n::Tests::Localization::Date
  include I18n::Tests::Localization::DateTime
  include I18n::Tests::Localization::Time
  include I18n::Tests::Localization::Procs

  test "make sure we use a backend with Pluralization included" do
    assert_equal Backend, I18n.backend.class
  end

  # links: test that keys stored on one backend can link to keys stored on another backend
end
