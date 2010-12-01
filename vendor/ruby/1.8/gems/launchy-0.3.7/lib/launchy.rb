module Launchy
  #
  # Utility method to require all files ending in .rb in the directory
  # with the same name as this file minus .rb
  #
  def self.require_all_libs_relative_to(fname)
    prepend   = File.basename(fname,".rb")
    search_me = File.join(File.dirname(fname),prepend)

    Dir.entries(search_me).each do |rb|
      if File.extname(rb) == ".rb" then
        require "#{prepend}/#{File.basename(rb,".rb")}"
      end
    end
  end

  class << self
    #
    # Convenience method to launch an item
    #
    def open(*params)
      begin
        klass = Launchy::Application.find_application_class_for(*params)
        if klass then
          klass.run(*params)
        else
          msg = "Unable to launch #{params.join(' ')}"
          Launchy.log "#{self.name} : #{msg}"
          $stderr.puts msg
        end
      rescue Exception => e
        msg = "Failure in opening #{params.join(' ')} : #{e}"
        Launchy.log "#{self.name} : #{msg}"
        $stderr.puts msg
      end
    end

    # Setting the LAUNCHY_DEBUG environment variable to 'true' will spew
    # debug information to $stderr
    def log(msg)
      if ENV['LAUNCHY_DEBUG'] == 'true' then
        $stderr.puts "LAUNCHY_DEBUG: #{msg}"
      end
    end

    # Create an instance of the commandline application of launchy
    def command_line
      Launchy::CommandLine.new
    end
  end
end

Launchy.require_all_libs_relative_to(__FILE__)
