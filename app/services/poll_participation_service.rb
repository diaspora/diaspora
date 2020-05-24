# frozen_string_literal: true

class PollParticipationService
  def initialize(user)
    @user = user
  end

  def vote(post_id, answer_id)
    answer = PollAnswer.find(answer_id)
    @user.participate_in_poll!(target(post_id), answer) if target(post_id)
  end

  private

  def target(post_id)
    @target ||= @user.find_visible_shareable_by_id(Post, post_id) || raise(ActiveRecord::RecordNotFound.new)
  end
end
