class Publisher
  attr_accessor :user, :open, :prefill, :public

  def initialize(user, opts={})
    self.user = user
    self.open = (opts[:open] == true)? true : false
    self.prefill = opts[:prefill]
    self.public = (opts[:public] == true)? true : false
  end

  def open?
    self.open
  end

  def public?
    self.public
  end
end
