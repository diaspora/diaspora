require 'statsample'

class Statistics

  attr_reader :start_time,
              :range

  def initialize
    #@start_time = start_time
    #@range = range
  end

  def posts_count_sql
    <<SQL
      SELECT users.id AS id, count(posts.id) AS count
        FROM users
          JOIN people ON people.owner_id = users.id
          LEFT OUTER JOIN posts ON people.id = posts.author_id
          GROUP BY users.id
SQL
  end

  def invites_sent_count_sql
    <<SQL
      SELECT users.id AS id, count(invitations.id) AS count
        FROM users
          LEFT OUTER JOIN invitations ON users.id = invitations.sender_id
          GROUP BY users.id
SQL
  end

  def tags_followed_count_sql
    <<SQL
      SELECT users.id AS id, count(tag_followings.id) AS count
        FROM users
          LEFT OUTER JOIN tag_followings on users.id = tag_followings.user_id
          GROUP BY users.id
SQL
  end

  def mentions_count_sql
    <<SQL
      SELECT users.id AS id, count(mentions.id) AS count
        FROM users
          JOIN people on users.id = people.owner_id
          LEFT OUTER JOIN mentions on people.id = mentions.person_id
          GROUP BY users.id
SQL
  end

  def sign_in_count_sql
    <<SQL
      SELECT users.id AS id, users.sign_in_count AS count
        FROM users
SQL
  end

  def post_count_correlation

    # [{"id" => 1 , "count" => 123}]

    x_array = []
    y_array = []

    post_count_hash.keys.each do |k| 
      if val = sign_in_count_hash[k]
        x_array << post_count_hash[k]
        y_array << val
      end
    end

    correlation(x_array, y_array)
  end


  ###\
  #def correlate(thing)
  #  sql = self.send("#{thing}_count_sql".to_sym)
  #  self.correlation(User.connection.select_all(sql), 
  #end


  ###

  def correlation(x_array, y_array)
    x = x_array.to_scale
    y = y_array.to_scale
    pearson = Statsample::Bivariate::Pearson.new(x,y)
    pearson.r
  end

  ### % of cohort came back last week
  def retention(n)
    week_created(n).where("current_sign_in_at > ?", Time.now - 1.week).count.to_f/week_created(n).count
  end

  protected
  def week_created(n)
    User.where("username IS NOT NULL").where("created_at > ? and created_at < ?", Time.now - (n+1).weeks, Time.now - n.weeks)
  end

  def post_count_hash
    unless @post_count_hash
      post_count_array = User.connection.select_all(self.posts_count_sql)

      @post_count_hash = {}
      post_count_array.each{ |h| @post_count_hash[h['id']] = h["count"]}
    end
    @post_count_hash
  end

  def sign_in_count_hash
    unless @sign_in_count_hash
      sign_in_count_array = User.connection.select_all(self.sign_in_count_sql)

      @sign_in_count_hash = {}
      sign_in_count_array.each{ |h| @sign_in_count_hash[h['id']] = h["count"]}
    end
    @sign_in_count_hash
  end
end
