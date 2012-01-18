class Person < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
end

class User < ActiveRecord::Base
  serialize :hidden_shareables, Hash
end

class Contact < ActiveRecord::Base
  belongs_to :user
end

class ShareVisibility < ActiveRecord::Base
  belongs_to :contact
end

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'share_visibility_converter')

class MoveRecentlyHiddenPostsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :hidden_shareables, :text
    ShareVisibilityConverter.copy_hidden_share_visibilities_to_users(true)
  end

  def self.down
    remove_column :users, :hidden_shareables
  end
end