if Rails.env == 'development'
  Rails.application.middleware.use(Oink::Middleware, :logger => Rails.logger)
end