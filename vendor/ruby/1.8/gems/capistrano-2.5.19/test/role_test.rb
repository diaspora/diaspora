require "utils"
require 'capistrano/role'

class RoleTest < Test::Unit::TestCase
  def test_clearing_a_populated_role_should_yield_no_servers
    role = Capistrano::Role.new("app1.capistrano.test", lambda { |o| "app2.capistrano.test" })
    assert_equal 2, role.servers.size
    role.clear
    assert role.servers.empty?
  end
end
