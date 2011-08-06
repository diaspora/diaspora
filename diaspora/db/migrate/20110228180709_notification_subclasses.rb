class NotificationSubclasses < ActiveRecord::Migration
  def self.up
    add_column :notifications, :type, :string, :null => :false
    {:new_request => 'Notifications::NewRequest',
      :request_accepted => 'Notifications::RequestAccepted',
      :comment_on_post => 'Notifications::CommentOnPost',
      :also_commented => 'Notifications::AlsoCommented',
      :mentioned => 'Notifications::Mentioned'
    }.each_pair do |key, value|
      execute("UPDATE notifications
              set type = '#{value}'
              where action = '#{key.to_s}'")
    end
    remove_column :notifications, :action
  end

  def self.down
    add_column :notifications, :action, :string
    {:new_request => 'Notifications::NewRequest',
      :request_accepted => 'Notifications::RequestAccepted',
      :comment_on_post => 'Notifications::CommentOnPost',
      :also_commented => 'Notifications::AlsoCommented',
      :mentioned => 'Notifications::Mentioned'
    }.each_pair do |key, value|
      execute("UPDATE notifications
              set action = '#{key.to_s}'
              where type = '#{value}'")
    end
    remove_column :notifications, :type
  end
end
