begin
  require 'ramaze'
rescue LoadError
  require 'rubygems'
  require 'ramaze'
end

class Main < Ramaze::Controller
  engine :ERB
  layout :default

  def index
    # just render views/index.html.erb
  end

  def add
    "Answer: #{request[:first].to_i + request[:second].to_i}"
  end
end

Ramaze.start :root => __DIR__
