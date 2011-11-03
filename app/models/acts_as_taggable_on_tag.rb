class ActsAsTaggableOn::Tag
  def followed_count
   @followed_count ||= TagFollowing.where(:tag_id => self.id).count
  end

  def self.autocomplete(name)
    where("name LIKE ?", "#{name.downcase}%")
  end

  def self.normalize(name)
    if name =~ /^#?<3/
      # Special case for love, because the world needs more love.
      '<3'
    elsif name
      name.gsub(/[^\w-]/, '')
    end
  end
end
