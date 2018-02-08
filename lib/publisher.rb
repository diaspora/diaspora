# frozen_string_literal: true

class Publisher
  attr_accessor :user, :open, :prefill, :public

  def initialize(user, opts={})
    self.user = user
    self.open = opts[:open]
    self.prefill = opts[:prefill]
    self.public = opts[:public]
  end
end
