class Publisher
  attr_accessor :user, :open, :prefill, :public, :explain

  def initialize(user, opts={})
    self.user = user
    self.open = opts[:open]
    self.prefill = opts[:prefill]
    self.public = opts[:public]
    self.explain = opts[:explain]
  end

  def text
    return unless prefill.present?
    Diaspora::MessageRenderer.new(
      prefill,
      mentioned_people: Diaspora::Mentionable.people_from_string(prefill)
    ).plain_text
  end
end
