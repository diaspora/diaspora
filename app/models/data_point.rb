class DataPoint < ActiveRecord::Base
  belongs_to :statistic

  def self.users_with_posts_on_day(time, number)
    sql = ActiveRecord::Base.connection()
    value = sql.execute("SELECT COUNT(*) FROM (SELECT COUNT(*) AS post_sum, person_id FROM posts WHERE created_at >= '#{(time - 1.days).utc.to_datetime}' AND created_at <= '#{time.utc.to_datetime}' GROUP BY person_id) AS t1 WHERE t1.post_sum = #{number};").first[0]
    self.new(:key => number.to_s, :value => value)
  end
end
