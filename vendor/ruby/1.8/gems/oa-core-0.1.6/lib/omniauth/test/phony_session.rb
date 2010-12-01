class OmniAuth::Test::PhonySession
  def initialize(app); @app = app end
  def call(env)
    @session ||= (env['rack.session'] || {})
    env['rack.session'] = @session
    @app.call(env)
  end
end
