class AdminRack
  def initialize(app)
    @app = app
  end

  def call(env)
    user = env['warden'].authenticate(:scope => :user)
    if user && user.admin?
      @app.call(env)
    else
      [307, {"Location" => '/'}, self]
    end
  end

  def each(&block)
  end
end


