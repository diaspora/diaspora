module User::SocialActions
  def comment!(post, text, opts={})
    participations.where(:target_id => post).first || participate!(post)
    Comment::Generator.new(self.person, post, text).create!(opts)
  end

  def participate!(target, opts={})
    Participation::Generator.new(self.person, target).create!(opts)
  end

  def like!(target, opts={})
    participations.where(:target_id => target).first || participate!(target)
    Like::Generator.new(self.person, target).create!(opts)
  end

  def build_comment(options={})
    Comment::Generator.new(self.person, options.delete(:post), options.delete(:text)).build(options)
  end
end