module CsvGenerator

  PATH = '/usr/local/app/diaspora'
  BACKER_CSV_LOCATION = File.join('/usr/local/app/diaspora/', 'backer_list.csv')
  WAITLIST_LOCATION = File.join(Rails.root, 'config', 'mailing_list.csv')
  OFFSET_LOCATION = File.join(Rails.root, 'config', 'email_offset')

  def self.all_active_users
    file = self.filename("all_active_users")
    sql = <<SQL
      SELECT email AS '%EMAIL%' 
        #{self.output_syntax(file)}
        FROM users where username IS NOT NULL
SQL
    ActiveRecord::Base.execute(sql)
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
    ActiveRecord::Base.execute(sql)
  end

  def self.backers_recent_login
    file = self.filename("v1_backers_recent_login.csv")
    sql = <<SQL
          SELECT email AS '%EMAIL%',
                 coalesce( full_name, 'friend of Diaspora*') AS '%NAME%',
                 invitation_token AS '%TOKEN%'
              #{self.output_syntax(file)}
           FROM `users` 
          WHERE #{self.backer_email_condition}
            AND (last_sign_in_at >= #{(Time.now - 1.month).to_i})
SQL
  end

  def self.backers_older_login
    file = self.filename("v1_backers_recent_login.csv")
    sql = <<SQL
          SELECT email AS '%EMAIL%',
                 coalesce( full_name, 'friend of Diaspora*') AS '%NAME%',
                 invitation_token AS '%TOKEN%'
              #{self.output_syntax(file)}
           FROM `users` 
          WHERE #{self.backer_email_condition}
            AND (last_sign_in_at < #{(Time.now - 1.month).to_i})
SQL
  end


  # ---------------- QUERY METHODS & NOTES -------------------------
  def self.backer_email_condition
    "`users`.`email` IN (#{query_string_from_array(self.backer_emails)})" 
  end

  def self.recent_login_query

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
    csv = filename
    if RUBY_VERSION.include? "1.8"
      require 'fastercsv'
       people = FasterCSV.read(csv)
     else
       require 'csv'
       people = CSV.read(csv)
     end
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
end
