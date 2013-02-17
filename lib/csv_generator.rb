module CsvGenerator

  PATH = '/tmp/'
  BACKER_CSV_LOCATION = File.join('/usr/local/app/diaspora/', 'backer_list.csv')
  #BACKER_CSV_LOCATION = File.join('/home/ilya/workspace/diaspora/', 'backer_list.csv')
  WAITLIST_LOCATION = Rails.root.join('config', 'mailing_list.csv')
  OFFSET_LOCATION = Rails.root.join('config', 'email_offset')
  UNSUBSCRIBE_LOCATION = Rails.root.join('config', 'unsubscribe.csv')

  def self.all_active_users
    file = self.filename("all_active_users")
    sql = <<SQL
      SELECT email AS '%EMAIL%' 
        #{self.output_syntax(file)}
        FROM users where username IS NOT NULL
SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.all_inactive_invited_users
    file = self.filename("all_inactive_invited_users.csv")
    sql = <<SQL
      SELECT invitations.identifier AS '%EMAIL%', users.invitation_token AS '%TOKEN%'
        #{self.output_syntax(file)}
        FROM invitations
        JOIN users ON
          users.id=invitations.recipient_id
          WHERE users.username IS NULL
            AND invitations.service='email'
SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.generate_csvs
    #`mkdir /tmp/csvs`
    self.backers_recent_login
    self.backers_old_login
    self.backers_never_login
    self.non_backers_recent_login
    self.non_backers_old_login
    self.non_backers_never_login
  end

  def self.all_users
    file = self.filename("v1_9_20_all_users.csv")
    sql = self.select_fragment(file, "#{self.has_email}" +
                                " AND #{self.unsubscribe_email_condition}")

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.backers_recent_login
    file = self.filename("v1_backers_recent_login.csv")
    sql = self.select_fragment(file, "#{self.has_email} AND #{self.backer_email_condition}" +
                                " AND #{self.unsubscribe_email_condition} AND #{self.recent_login_query}")

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.backers_old_login
    file = self.filename("v2_backers_old_login.csv")
    sql = self.select_fragment(file, "#{self.has_email} AND #{self.backer_email_condition} " +
                                " AND #{self.unsubscribe_email_condition} AND #{self.old_login_query}")

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.backers_never_login
    #IF(`users`.invitation_token,   ,NULL)
    file = self.filename("v3_backers_never_login.csv")
    sql = <<SQL
          SELECT '%EMAIL%','%NAME%','%INVITATION_LINK%'
          UNION
            SELECT `users`.email AS '%EMAIL%',
                    'Friend of Diaspora*' AS '%NAME%',
                CONCAT( 'https://joindiaspora.com/users/invitation/accept?invitation_token=', `users`.invitation_token) AS '%INVITATION_LINK%'
                #{self.output_syntax(file)}
             FROM `users`
            WHERE #{self.has_email} AND #{self.has_invitation_token} AND #{self.backer_email_condition} AND #{self.unsubscribe_email_condition} AND #{self.never_login_query};
SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.non_backers_recent_login
    file = self.filename("v4_non_backers_recent_login.csv")
    sql = self.select_fragment(file, "#{self.has_email} AND #{self.non_backer_email_condition} " +
                                "AND #{self.unsubscribe_email_condition} AND #{self.recent_login_query}")

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.non_backers_old_login
    file = self.filename("v5_non_backers_old_login.csv")
    sql = self.select_fragment(file, "#{self.has_email} AND #{self.non_backer_email_condition} " +
                                "AND #{self.unsubscribe_email_condition} AND #{self.old_login_query}")

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.non_backers_never_login
    file = self.filename("v6_non_backers_never_login.csv")
    sql = <<SQL
          SELECT '%EMAIL%','%NAME%','%INVITATION_LINK%'
          UNION
            SELECT `users`.email AS '%EMAIL%',
                    'Friend of Diaspora*' AS '%NAME%',
                CONCAT( 'https://joindiaspora.com/users/invitation/accept?invitation_token=', `users`.invitation_token) AS '%INVITATION_LINK%'
                #{self.output_syntax(file)}
             FROM `users`
            WHERE #{self.has_email} AND #{self.has_invitation_token} AND #{self.non_backer_email_condition} AND #{self.unsubscribe_email_condition} AND #{self.never_login_query};
SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.non_backers_logged_in
    file = self.filename("v2_non_backers.csv")
    sql = self.select_fragment(file, "#{self.has_email} AND #{self.non_backer_email_condition} " +
                                "AND #{self.unsubscribe_email_condition} AND #{self.has_username}")

    ActiveRecord::Base.connection.execute(sql)
  end

  # ---------------- QUERY METHODS & NOTES -------------------------
  def self.select_fragment(file, where_clause)
    sql = <<SQL
          SELECT '%EMAIL%','%NAME%','%INVITATION_LINK%'
          UNION
            SELECT `users`.email AS '%EMAIL%',
                   IF( `profiles`.first_name IS NOT NULL AND `profiles`.first_name != "",
                                               `profiles`.first_name, 'Friend of Diaspora*') AS '%NAME%',
                IF(`users`.invitation_token, CONCAT( 'https://joindiaspora.com/users/invitation/accept?invitation_token=', `users`.invitation_token) ,NULL) AS '%INVITATION_LINK%'
                #{self.output_syntax(file)}
             FROM `users`
             JOIN `people` ON `users`.id = `people`.owner_id JOIN `profiles` ON `people`.id = `profiles`.person_id
            WHERE #{where_clause};
SQL
  end

  def self.has_username
    '`users`.`username` IS NOT NULL'
  end
  
  def self.has_invitation_token
    '`users`.`invitation_token` IS NOT NULL'
  end
  
  def self.has_email
    '`users`.`email` IS NOT NULL AND `users`.`email` != ""'
  end

  def self.backer_email_condition
    b_emails = self.backer_emails
    b_emails.map!{|a| "'#{a}'"}
    "`users`.`email` IN (#{query_string_from_array(b_emails[1..b_emails.length])})" 
  end

  def self.non_backer_email_condition
    b_emails = self.backer_emails
    b_emails.map!{|a| "'#{a}'"}
    "`users`.`email` NOT IN (#{query_string_from_array(b_emails[1..b_emails.length])})" 
  end

  def self.unsubscribe_email_condition
    u_emails = self.unsubscriber_emails
    u_emails.map!{|a| "'#{a}'"}
    "`users`.`email` NOT IN (#{query_string_from_array(u_emails[1..u_emails.length])})" 
  end

  def self.recent_login_query
    "(last_sign_in_at > SUBDATE(NOW(), INTERVAL 31 DAY))"
  end

  def self.old_login_query
    "(last_sign_in_at < SUBDATE(NOW(), INTERVAL 31 DAY))"
  end

  def self.never_login_query
    "(last_sign_in_at IS NULL)"
  end
  
  def self.query_string_from_array(array)
    array.join(", ")
  end
  
  # BACKER RECENT LOGIN
  # User.where("last_sign_in_at > ?", (Time.now - 1.month).to_i).where(:email => ["maxwell@joindiaspora.com"]).count
  #
  # "SELECT `users`.* FROM `users` WHERE `users`.`email` IN ('maxwell@joindiaspora.com') AND (last_sign_in_at > 1312663724)"

  # NON BACKER RECENT LOGIN
  # User.where("last_sign_in_at > ?", (Time.now - 1.month).to_i).where("email NOT IN (?)", 'maxwell@joindiaspora.com').to_sql
  # "SELECT `users`.* FROM `users` WHERE (last_sign_in_at > 1312665370) AND (email NOT IN ('maxwell@joindiaspora.com'))" 
 



  # ---------------- HELPER METHODS -------------------------
  def self.load_waiting_list_csv(filename)
    require 'csv'
    csv = filename
    people = CSV.read(csv)
    people
  end

  def self.offset
    offset_filename = OFFSET_LOCATION
    File.read(offset_filename).to_i
  end

  def self.filename(name)
    "#{PATH}#{Time.now.strftime("%Y-%m-%d")}-#{name}"
  end

  def self.output_syntax filename
    <<SQL
    INTO OUTFILE '#{filename}'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
SQL
  end

  def self.waitlist
    people = self.load_waiting_list_csv(WAITLIST_LOCATION)
    offset = self.offset
    left = people[0...offset]
    right = people[offset...people.size]

    #reading from csv (get number of row we're on) - left
    #reading from csv (get number of row we're on) - right
  end

  def self.backers
    self.load_waiting_list_csv(BACKER_CSV_LOCATION)
  end

  def self.backer_emails
    self.backers.map{|b| b[0]}
  end

  def self.unsubsribers
    self.load_waiting_list_csv(UNSUBSCRIBE_LOCATION)
  end

  def self.unsubscriber_emails
    self.unsubsribers.map{|b| b[1]}
  end
end
