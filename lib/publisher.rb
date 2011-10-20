class Publisher
  attr_accessor :user, :open, :prefill, :public, :explain

  def initialize(user, opts={})
    self.user = user
    self.open = (opts[:open] == true)? true : false
    self.prefill = opts[:prefill]
    self.public = (opts[:public] == true)? true : false
    self.explain = (opts[:explain] == true)? true : false
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
end
