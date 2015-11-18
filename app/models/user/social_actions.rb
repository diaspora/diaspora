module User::SocialActions
  def comment!(target, text, opts={})
    Comment::Generator.new(self, target, text).create!(opts).tap do
      find_or_create_participation!(target)
    end
  end

  def participate!(target, opts={})
    Participation::Generator.new(self, target).create!(opts)
  end

  def like!(target, opts={})
    Like::Generator.new(self, target).create!(opts).tap do
      find_or_create_participation!(target)
    end
  end

  def participate_in_poll!(target, answer, opts={})
    PollParticipation::Generator.new(self, target, answer).create!(opts).tap do
      find_or_create_participation!(target)
    end
  end

  def reshare!(target, opts={})
    build_post(:reshare, :root_guid => target.guid).tap do |reshare|
      reshare.save!
      find_or_create_participation!(target)
      Postzord::Dispatcher.defer_build_and_post(self, reshare)
    end
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
