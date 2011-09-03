module CsvGenerator

  PATH = '/Users/maxwell/Sites/dump'

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

  def self.waitlist
    filename = File.join(Rails.root, 'config', 'mailing_list.csv')

    people = self.load_waiting_list_csv
    offset = self.offset
    left = people[0...offset]
    right = people[offset...people.size]

    #reading from csv (get number of row we're on) - left
    #reading from csv (get number of row we're on) - right
  end

  def self.load_waiting_list_csv
    csv= File.join(Rails.root, 'config', 'mailing_list.csv')
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
    offset_filename = File.join(Rails.root, 'config', 'email_offset')
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
end
