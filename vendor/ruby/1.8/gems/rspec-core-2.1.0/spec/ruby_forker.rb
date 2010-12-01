require 'rbconfig'

module RubyForker
  # Forks a ruby interpreter with same type as ourself.
  # jruby will fork jruby, ruby will fork ruby etc.
  def ruby(args, stderr=nil)
    config       = ::RbConfig::CONFIG
    interpreter  = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
    cmd = "#{interpreter} #{args}"
    cmd << " 2> #{stderr}" unless stderr.nil?
    `#{cmd}`
  end
end
