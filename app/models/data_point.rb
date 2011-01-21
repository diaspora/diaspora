class DataPoint < ActiveRecord::Base
  belongs_to :statistic

  def self.users_with_posts_on_day(time, number)
    sql = ActiveRecord::Base.connection()
    value = sql.execute("SELECT COUNT(*) FROM (SELECT COUNT(*) AS post_sum, DATE(created_at) AS date, person_id FROM posts GROUP BY person_id, date HAVING date = '#{time.utc.to_date}') AS t1 WHERE t1.post_sum = #{number};").first[0]
    self.new(:key => number.to_s, :value => value)
  end
end
