$LOAD_PATH.unshift "../net-ssh/lib"
require './lib/net/sftp/version'

begin
  require 'echoe'
rescue LoadError
  abort "You'll need to have `echoe' installed to use Net::SFTP's Rakefile"
end

version = Net::SFTP::Version::STRING.dup
if ENV['SNAPSHOT'].to_i == 1
  version << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end

Echoe.new('net-sftp', version) do |p|
  p.project          = "net-ssh"
  p.changelog        = "CHANGELOG.rdoc"

  p.author           = "Jamis Buck"
  p.email            = "netsftp@solutious.com"
  p.summary          = "A pure Ruby implementation of the SFTP client protocol"
  p.url              = "http://net-ssh.rubyforge.org/sftp"

  p.dependencies     = ["net-ssh >=2.0.9"]

  p.need_zip         = true
  p.include_rakefile = true

  p.rdoc_pattern     = /^(lib|README.rdoc|CHANGELOG.rdoc)/
end
