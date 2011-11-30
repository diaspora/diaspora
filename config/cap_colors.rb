require 'capistrano_colors'    

capistrano_color_matchers = [
  # Full docs at https://github.com/stjernstrom/capistrano_colors/
  # Any priority above 0 will override capistrano_colors' defaults if needed
  { :match => /^Deploying branch/, :color => :yellow, :prio => 20 },
]

capistrano_color_matchers.each do |matcher|
  Capistrano::Logger::add_color_matcher( matcher )
end
