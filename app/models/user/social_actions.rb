module User::SocialActions
  def comment!(target, text, opts={})
    participations.where(:target_id => target).first || participate!(target)
    Comment::Generator.new(self, target, text).create!(opts)
  end

  def participate!(target, opts={})
    Participation::Generator.new(self, target).create!(opts)
  end

  def like!(target, opts={})
    participations.where(:target_id => target).first || participate!(target)
    Like::Generator.new(self, target).create!(opts)
  end

  def build_comment(options={})
    Comment::Generator.new(self, options.delete(:post), options.delete(:text)).build(options)
  end
end