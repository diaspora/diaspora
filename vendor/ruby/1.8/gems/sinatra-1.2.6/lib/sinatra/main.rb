require 'sinatra/base'

module Sinatra
  class Application < Base

    # we assume that the first file that requires 'sinatra' is the
    # app_file. all other path related options are calculated based
    # on this path by default.
    set :app_file, caller_files.first || $0

    set :run, Proc.new { $0 == app_file }

    if run? && ARGV.any?
      require 'optparse'
      OptionParser.new { |op|
        op.on('-x')        {       set :lock, true }
        op.on('-e env')    { |val| set :environment, val.to_sym }
        op.on('-s server') { |val| set :server, val }
        op.on('-p port')   { |val| set :port, val.to_i }
        op.on('-o addr')   { |val| set :bind, val }
      }.parse!(ARGV.dup)
    end
  end

  at_exit { Application.run! if $!.nil? && Application.run? }
end

include Sinatra::Delegator
