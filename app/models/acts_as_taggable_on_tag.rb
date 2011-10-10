class ActsAsTaggableOn::Tag 
  def followed_count
   @followed_count ||= TagFollowing.where(:tag_id => self.id).count
  end

  def self.autocomplete(name)
    where("name LIKE ?", "#{name.downcase}%")
  end
end
