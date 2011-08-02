class Project < ActiveRecord::Base
  has_and_belongs_to_many :developers, :uniq => true
  
  has_many :topics
    # :finder_sql  => 'SELECT * FROM topics WHERE (topics.project_id = #{id})',
    # :counter_sql => 'SELECT COUNT(*) FROM topics WHERE (topics.project_id = #{id})'
  
  has_many :replies, :through => :topics do
    def only_recent(params = {})
      scoped.where(['replies.created_at > ?', 15.minutes.ago])
    end
  end
end
