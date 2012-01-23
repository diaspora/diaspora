if AppConfig[:image_redirect_url].present?
  require 'rack-rewrite'

  Rails.application.config.middleware.insert(0, Rack::Rewrite) do
    r301 %r{/uploads/images/(.*)}, "#{AppConfig[:image_redirect_url]}/uploads/images/$1"
  end
end