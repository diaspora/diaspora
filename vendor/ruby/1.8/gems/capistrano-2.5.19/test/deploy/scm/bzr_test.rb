require "utils"
require 'capistrano/recipes/deploy/scm/bzr'

class DeploySCMBzrTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Bzr
    default_command "bzr"
  end

  def setup
    @config = { :repository => "." }

    def @config.exists?(name); key?(name); end # is this actually needed?

    @source = TestSCM.new(@config)
  end

  # The bzr scm does not support pseudo-ids. The bzr adapter uses symbol :head
  # to refer to the recently committed revision.
  def test_head_revision
    assert_equal(:head,
                 @source.head,
                 "Since bzr doesn't know a real head revision, symbol :head is used instead.")
  end

  # The bzr scm does support many different ways to specify a revision. Only
  # symbol :head triggers the bzr command 'revno'.
  def test_query_revision
    assert_equal("bzr revno #{@config[:repository]}",
                 @source.query_revision(:head) { |o| o },
                 "Query for :head revision should call bzr command 'revno' in repository directory.")

    # Many valid revision specifications, some invalid on the last line
    revision_samples = [ 5, -7, '2', '-4',
                         'revid:revid:aaaa@bbbb-123456789',
                         'submit:',
                         'ancestor:/path/to/branch',
                         'date:yesterday',
                         'branch:/path/to/branch',
                         'tag:trunk',
                         'revno:3:/path/to/branch',
                         'before:revid:aaaa@bbbb-1234567890',
                         'last:3',
                         nil, {}, [], true, false, 1.34, ]
    
    revision_samples.each do |revivsion_spec|
      assert_equal(revivsion_spec,
                   @source.query_revision(revivsion_spec),
                   "Any revision specification other than symbol :head should simply by returned.")
    end
  end
end
