module User::SocialActions
  def comment!(target, text, opts={})
    find_or_create_participation!(target)
    Comment::Generator.new(self, target, text).create!(opts)
  end

  def participate!(target, opts={})
    Participation::Generator.new(self, target).create!(opts)
  end

  def like!(target, opts={})
    find_or_create_participation!(target)
    Like::Generator.new(self, target).create!(opts)
  end

  def participate_in_poll!(target, answer, opts={})
    find_or_create_participation!(target)
    PollParticipation::Generator.new(self, target, answer).create!(opts)
  end

  def reshare!(target, opts={})
    find_or_create_participation!(target)
    reshare = build_post(:reshare, :root_guid => target.guid)
    reshare.save!
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

  def find_or_create_participation!(target)
    participations.where(:target_id => target).first || participate!(target)
  end
end
