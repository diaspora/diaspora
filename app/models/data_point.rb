class DataPoint < ActiveRecord::Base
  belongs_to :statistic

  def self.users_with_posts_today(number)
    sql = ActiveRecord::Base.connection()
    value = sql.execute(
      "SELECT COUNT(*) FROM (SELECT `people`.guid, COUNT(*) AS posts_sum FROM `people` LEFT JOIN `posts` ON `people`.id = `posts`.person_id AND `posts`.created_at > '#{(Time.now - 1.days).to_date}' GROUP BY `people`.guid) AS t1 WHERE t1.posts_sum = #{number};"
    ).first[0]

    self.new(:key => number, :value => value)
  end
end
