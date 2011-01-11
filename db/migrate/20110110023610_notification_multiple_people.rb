class NotificationMultiplePeople < ActiveRecord::Migration
  def self.up
    create_table :notification_actors do |t|
      t.integer :notification_id
      t.integer :person_id
      t.timestamps
    end
    
    add_index :notification_actors, :notification_id
    add_index :notification_actors, [:notification_id, :person_id] , :unique => true
    add_index :notification_actors, :person_id  ## if i am not mistaken we don't need this one because we won't query person.notifications

    execute "INSERT INTO notification_actors (notification_id, person_id) " +
      " SELECT id , actor_id " +
      " FROM notifications"
    
    #TODO in sql
    # 1) set target type
    # 2) update the target_id from the comment to comment.post_id
    execute "UPDATE notifications "+
           " SET target_id = comment.post_id, target_type = 'post' " +
           " FROM notifications " +
           " INNER JOIN comments " +
           " WHERE notifications.target_id = comments.id "


    #bump up target to status message id if comment_on_post, also_commented
    ['comment_on_post', 'also_commented'].each do |type|

    Notification.joins(:target).where(:action => "comment_on_post").update_all(:target => target)
          

    Notification.where(:action => 'comment_on_post').all.each{|n|
      n.target_id => Comment.find(n.target_id).post}

    #for each user
    all = Notification.where(:type => 'comment_on_post', :user => user).all
    first = all.first
    all[1..all.length-1].each{ |a|
      first << a.notification_actors
      a.delete
    }

    end
    
    # all notification of same type with the same 


    remove_column :notification, :actor_id
  end

  def self.down
    remove_index :notification_actors, :notification_id
    remove_index :notification_actors, [:notification_id, :person_id]
    remove_index :notification_actors, :person_id
    
    drop_table :notification_actors
  end
end
