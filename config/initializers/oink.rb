if Rails.env == 'development'
  if defined?(Oink)
    Rails.application.middleware.use(Oink::Middleware, :logger => Rails.logger)
  else
    $stderr.puts "WARNING:"
    $stderr.puts "  You run in development but Oink isn't available in your gems."
    $stderr.puts "  That most likely means you copied the bundle command from the installation guide"
    $stderr.puts "  and didn't removed development from the --without parameter while having"
    $stderr.puts "  the intention to run under development mode. To fix this either switch to"
    $stderr.puts "  production mode or do a rm .bundle/config and run bundle install --without heroku"
  end
end
