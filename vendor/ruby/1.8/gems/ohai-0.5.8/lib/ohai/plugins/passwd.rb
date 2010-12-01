provides 'etc', 'current_user'

require 'etc'

unless etc
  etc Mash.new

  etc[:passwd] = Mash.new
  etc[:group] = Mash.new
  
  Etc.passwd do |entry|
    etc[:passwd][entry.name] = Mash.new(:dir => entry.dir, :gid => entry.gid, :uid => entry.uid, :shell => entry.shell, :gecos => entry.gecos)
  end
  
  Etc.group do |entry|
    etc[:group][entry.name] = Mash.new(:gid => entry.gid, :members => entry.mem)
  end
end

unless current_user
  current_user Etc.getlogin
end