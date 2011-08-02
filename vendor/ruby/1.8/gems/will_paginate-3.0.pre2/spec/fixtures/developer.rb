class Developer < User
  has_and_belongs_to_many :projects, :include => :topics, :order => 'projects.name'

  def self.with_poor_ones(&block)
    with_scope :find => { :conditions => ['salary <= ?', 80000], :order => 'salary' } do
      yield
    end
  end

  scope :poor, :conditions => ['salary <= ?', 80000], :order => 'salary'

  def self.per_page() 10 end
end
