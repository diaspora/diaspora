class UserSession
  include Mongoid::Document

  def authenticates(name, password)
    user = User.first(:conditions => {:name => name, :password => password})
    self.save unless user.nil? 
  end
end
