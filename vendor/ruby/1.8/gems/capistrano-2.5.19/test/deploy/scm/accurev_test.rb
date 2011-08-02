require "utils"
require 'capistrano/recipes/deploy/scm/accurev'

class AccurevTest < Test::Unit::TestCase
  include Capistrano::Deploy::SCM

  def test_internal_revision_to_s
    assert_equal 'foo/1', Accurev::InternalRevision.new('foo', 1).to_s
    assert_equal 'foo/highest', Accurev::InternalRevision.new('foo', 'highest').to_s
  end

  def test_internal_revision_parse
    revision = Accurev::InternalRevision.parse('foo')
    assert_equal 'foo', revision.stream
    assert_equal 'highest', revision.transaction_id
    assert_equal 'foo/highest', revision.to_s

    revision = Accurev::InternalRevision.parse('foo/1')
    assert_equal 'foo', revision.stream
    assert_equal '1', revision.transaction_id
    assert_equal 'foo/1', revision.to_s
  end
end
