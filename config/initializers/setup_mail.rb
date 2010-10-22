ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?  
