class FakeHttpRequest
  def initialize(callback_wanted)
    @callback = callback_wanted
    @callbacks = []
  end

  def callbacks=(rs)
    @callbacks += rs.reverse
  end

  def response
    @callbacks.pop unless @callbacks.nil? || @callbacks.empty?
  end

  def response_header
    self
  end

  def method_missing(method)
    self
  end

  def post(opts = nil);
    self
  end

  def get(opts = nil)
    self
  end

  def publish(opts = nil)
    self
  end

  def callback(&b)
    b.call if @callback == :success
  end

  def errback(&b)
    b.call if @callback == :failure
  end
end
