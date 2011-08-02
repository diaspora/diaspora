require "utils"
require 'capistrano/recipes/deploy/scm/darcs'

class DeploySCMDarcsTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Darcs
    default_command "darcs"
  end
  def setup
    @config = { :repository => "." }
  #  def @config.exists?(name); key?(name); end

    @source = TestSCM.new(@config)
  end

  # We should be able to pick a specific hash.
  def test_checkout_hash
    hsh = "*version_hash*"
    assert_match(%r{--to-match=.hash #{Regexp.quote(hsh)}}, 
                 @source.checkout(hsh, "*foo_location*"),
                "Specifying a revision hash got the --to-match option wrong.")
  end

  # Picking the head revision should leave out the hash, because head is the
  # default and we don't have a HEAD pseudotag
  def test_checkout_head
    hsh = @source.head
    assert_no_match(%r{--to-match}, @source.checkout(hsh, "*foo_location*"),
                    "Selecting the head revision incorrectly produced a --to-match option.")
  end

  # Leaving the revision as nil shouldn't break anything.
  def test_checkout_nil
    assert_no_match(%r{--to-match}, @source.checkout(nil, "*foo_location*"),
                    "Leaving the revision as nil incorrectly produced a --to-match option.") 
  end
end

