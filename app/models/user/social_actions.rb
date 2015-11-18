module User::SocialActions
  def comment!(target, text, opts={})
    comment = Comment::Generator.new(self, target, text).create!(opts)
    update_or_create_participation!(target)
    comment
  end

  def participate!(target, opts={})
    Participation::Generator.new(self, target).create!(opts)
  end

  def like!(target, opts={})
    like = Like::Generator.new(self, target).create!(opts)
    update_or_create_participation!(target)
    like
  end

  def participate_in_poll!(target, answer, opts={})
    poll_participation = PollParticipation::Generator.new(self, target, answer).create!(opts)
    update_or_create_participation!(target)
    poll_participation
  end

  def reshare!(target, opts={})
    reshare = build_post(:reshare, :root_guid => target.guid)
    reshare.save!
    update_or_create_participation!(target)
    Postzord::Dispatcher.defer_build_and_post(self, reshare)
    reshare
  end

  def build_comment(options={})
    Comment::Generator.new(self, options.delete(:post), options.delete(:text)).build(options)
  end

  def build_conversation(opts={})
    Conversation.new do |c|
      c.author = self.person
      c.subject = opts[:subject]
      c.participant_ids = [*opts[:participant_ids]] | [self.person_id]
      c.messages_attributes = [
        { author: self.person, text: opts[:message][:text] }
      ]
    end
  end

  def build_message(conversation, opts={})
    conversation.messages.build(
      text: opts[:text],
      author: self.person
    )
  end

  def update_or_create_participation!(target)
    participation = participations.where(target_id: target).first
    if participation.present?
      participation.update!(count: participation.count.next)
    else
      participate!(target)
    end
  end
end
