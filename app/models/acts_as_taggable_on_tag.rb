class ActsAsTaggableOn::Tag 
  def followed_count
   @followed_count ||= TagFollowing.where(:tag_id => self.id).count
  end
end
