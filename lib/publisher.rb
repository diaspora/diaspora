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
    formatted_message
  end

  def open?
    open
  end

  def public?
    public
  end

  def explain?
    explain
  end

  private

  def formatted_message
    if prefill.present?
      sm = StatusMessage.new(text: prefill)
      Diaspora::Mentionable.format(sm.raw_message, sm.mentioned_people, plain_text: true)
    end
  end
end
