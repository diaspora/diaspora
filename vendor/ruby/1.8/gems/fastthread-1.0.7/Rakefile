
require 'rubygems'
gem 'echoe', '>=2.7.11'
require 'echoe'

Echoe.new("fastthread") do |p|
  p.project = "mongrel"
  p.author = "MenTaLguY <mental@rydia.net>"
  p.email = "mental@rydia.net"
  p.summary = "Optimized replacement for thread.rb primitives"
  p.extensions = "ext/fastthread/extconf.rb"
  p.clean_pattern = ['build/*', '**/*.o', '**/*.so', '**/*.a', 'lib/*-*', '**/*.log', "ext/fastthread/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/fastthread/Makefile", "pkg", "lib/*.bundle", "*.gem", ".config"]

  p.need_tar_gz = false
  p.need_tgz = true
  p.require_signed = false

  p.eval = proc do
    if Platform.windows?
      self.platform = Gem::Platform::CURRENT
      self.files += ['lib/fastthread.so']
      task :package => [:clean, :compile]
    end
  end

end
