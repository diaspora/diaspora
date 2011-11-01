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
    self.open
  end

  def public?
    self.public
  end

  def explain?
    self.explain
  end

  private
  def formatted_message
    if self.prefill.present?
      StatusMessage.new(:text => self.prefill).
        format_mentions(self.prefill, :plain_text => true)
    end
  end
end
