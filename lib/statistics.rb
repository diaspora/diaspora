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
          #{self.where_clause_sql}
          GROUP BY users.id
SQL
  end

  def comments_count_sql
    <<SQL
      SELECT users.id AS id, count(comments.id) AS count
        FROM users
          JOIN people ON people.owner_id = users.id
          LEFT OUTER JOIN comments ON people.id = comments.author_id
          #{self.where_clause_sql}
          GROUP BY users.id
SQL
  end

  def invites_sent_count_sql
    <<SQL
      SELECT users.id AS id, count(invitations.id) AS count
        FROM users
          LEFT OUTER JOIN invitations ON users.id = invitations.sender_id
          #{self.where_clause_sql}
          GROUP BY users.id
SQL
  end

  def tags_followed_count_sql
    <<SQL
      SELECT users.id AS id, count(tag_followings.id) AS count
        FROM users
          LEFT OUTER JOIN tag_followings on users.id = tag_followings.user_id
          #{self.where_clause_sql}
          GROUP BY users.id
SQL
  end

  def mentions_count_sql
    <<SQL
      SELECT users.id AS id, count(mentions.id) AS count
        FROM users
          JOIN people on users.id = people.owner_id
          LEFT OUTER JOIN mentions on people.id = mentions.person_id
          #{self.where_clause_sql}
          GROUP BY users.id
SQL
  end

  def contacts_sharing_with_count_sql
    <<SQL
      SELECT users.id AS id, count(contacts.id) AS count
        FROM users
          JOIN contacts on contacts.user_id = users.id
          JOIN aspect_memberships on aspect_memberships.contact_id = contacts.id
          #{self.where_clause_sql}
          GROUP BY users.id
SQL
  end

  def fb_connected_distribution_sql
    <<SQL
      SELECT users.id AS id, users.sign_in_count AS count, count(services.id) AS connected
        FROM users
          LEFT OUTER JOIN services on services.user_id = users.id
            AND services.type = 'Services::Facebook'
          #{self.where_clause_sql}
          GROUP BY users.id, users.sign_in_count
SQL
  end

  def fb_connected_distribution
    User.connection.select_all(fb_connected_distribution_sql).map { |row|
      Hash[
        row.map { |k,v|
          [k, v.to_i]
        }
      ]
    }
  end

  def sign_in_count_sql
    <<SQL
      SELECT users.id AS id, users.sign_in_count AS count
        FROM users
        #{self.where_clause_sql}
SQL
  end

  def correlate(first_metric, second_metric)

    # [{"id" => 1 , "count" => 123}]

    x_array = []
    y_array = []

    self.result_hash(first_metric).keys.each do |k|
      if val = self.result_hash(second_metric)[k]
        x_array << self.result_hash(first_metric)[k]
        y_array << val
      end
    end

    correlation(x_array, y_array)
  end

  def generate_correlations
    result = {}
    [:posts_count, :comments_count, :invites_sent_count, #:tags_followed_count,
     :mentions_count, :contacts_sharing_with_count].each do |metric|
      result[metric] = self.correlate(metric,:sign_in_count)
     end
    result
  end

  def correlation(x_array, y_array)
    sum = 0.0
    x_array.each_index do |i|
      sum = sum + x_array[i].to_f * y_array[i].to_f
    end
    x_y_mean = sum/x_array.length.to_f
    x_mean = mean(x_array)
    y_mean = mean(y_array)

    st_dev_x = standard_deviation(x_array)
    st_dev_y = standard_deviation(y_array)

    (x_y_mean - (x_mean*y_mean))/(st_dev_x * st_dev_y)
  end

  def mean(array)
    sum = array.inject(0.0) do |sum, val|
      sum += val.to_f
    end
    sum / array.length
  end

  def standard_deviation(array)
    variance = lambda do
      m = mean(array)
      sum = 0.0
      array.each{ |v| sum += (v.to_f-m)**2 }
      sum/array.length.to_f
    end.call

    Math.sqrt(variance)
  end

  ### % of cohort came back last week
  def retention(n)
    users_by_week(n).count.to_f/week_created(n).count
  end

  def top_active_users(n)
    ten_percent_lim = (users_by_week(n).count.to_f * 0.3).ceil
    users_by_week(n).joins(:person => :profile).where('users.sign_in_count > 4').order("users.sign_in_count DESC").limit(ten_percent_lim).select('users.email, users.username, profiles.first_name, users.sign_in_count')
  end

  def users_by_week(n)
    week_created(n).where("current_sign_in_at > ?", Time.now - 1.week)
  end

  protected
  def where_clause_sql
    if AppConfig.postgres?
      "WHERE users.created_at > NOW() - '1 month'::INTERVAL"
    else
      "where users.created_at > FROM_UNIXTIME(#{(Time.now - 1.month).to_i})"
    end
  end

  def week_created(n)
    User.where("username IS NOT NULL").where("users.created_at > ? and users.created_at < ?", Time.now - (n+1).weeks, Time.now - n.weeks)
  end

  #@param [Symbol] input type
  #@returns [Hash] of resulting query
  def result_hash(type)
    instance_hash = self.instance_variable_get("@#{type.to_s}_hash".to_sym)
    unless instance_hash
      post_count_array = User.connection.select_all(self.send("#{type.to_s}_sql".to_sym))

      instance_hash = {}
      post_count_array.each{ |h| instance_hash[h['id']] = h["count"]}
      self.instance_variable_set("@#{type.to_s}_hash".to_sym, instance_hash)
    end
    instance_hash
  end
end
