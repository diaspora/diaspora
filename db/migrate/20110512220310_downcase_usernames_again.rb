require 'db/migrate/20110421120744_downcase_usernames'
class DowncaseUsernamesAgain < ActiveRecord::Migration
  def self.up
    DowncaseUsernames.up
  end

  def self.down
    DowncaseUsernames.down
  end
end
