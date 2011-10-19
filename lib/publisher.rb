class Publisher
  attr_accessor :user, :open, :prefill_text, :public

  def initialize(user, opts={})
    self.user = user
    self.open = (opts[:open] == true)? true : false
    self.prefill_text = opts[:prefill_text]
    self.public = (opts[:public] == true)? true : false
  end

  def open?
    self.open
  end

  def public?
    self.public
  end
end
