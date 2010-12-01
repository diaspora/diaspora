require "rubygems"
require 'hoe'

$LOAD_PATH.unshift('lib')

require 'net/ldap'

PKG_NAME    = 'net-ldap'
PKG_VERSION = Net::LDAP::VERSION
PKG_DIST    = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_TAR     = "pkg/#{PKG_DIST}.tar.gz"
MANIFEST    = File.read("Manifest.txt").split
MINRUBY     = "1.8.7"

Hoe.plugin :git

Hoe.spec PKG_NAME do
  self.version = PKG_VERSION
  self.rubyforge_name = PKG_NAME

  developer "Francis Cianfrocca", "blackhedd@rubyforge.org"
  developer "Emiel van de Laar", "gemiel@gmail.com"
  developer "Rory O'Connell", "rory.ocon@gmail.com"
  developer "Kaspar Schiess", "kaspar.schiess@absurd.li"
  developer "Austin Ziegler", "austin@rubyforge.org" 

  self.remote_rdoc_dir = ''
  rsync_args << ' --exclude=statsvn/'

  self.url = %W(http://net-ldap.rubyforge.org/ http://github.com/RoryO/ruby-net-ldap)

  self.summary = "Pure Ruby LDAP support library with most client features and some server features."
  self.changes = paragraphs_of(self.history_file, 0..1).join("\n\n")
  self.description = paragraphs_of(self.readme_file, 2..2).join("\n\n")

  extra_dev_deps << [ "archive-tar-minitar", "~>0.5.1" ]
  extra_dev_deps << [ "hanna", "~>0.1.2" ]
  extra_dev_deps << [ "hoe-git", "~>1" ]
  clean_globs << "coverage"

  spec_extras[:required_ruby_version] = ">= #{MINRUBY}"
  multiruby_skip << "1.8.6"
  multiruby_skip << "1_8_6"

  # This is a lie because I will continue to use Archive::Tar::Minitar.
  self.need_tar        = false
end

desc "Build a Net-LDAP .tar.gz distribution."
task :tar => [ PKG_TAR ]
file PKG_TAR => [ :test ] do |t|
  require 'archive/tar/minitar'
  require 'zlib'
  files = MANIFEST.map { |f|
    fn = File.join(PKG_DIST, f)
    tm = File.stat(f).mtime

    if File.directory?(f)
      { :name => fn, :mode => 0755, :dir => true, :mtime => tm }
    else
      mode = if f =~ %r{^bin}
               0755
             else
               0644
             end
      data = File.read(f)
      { :name => fn, :mode => mode, :data => data, :size => data.size,
        :mtime => tm }
    end
  }

  begin
    unless File.directory?(File.dirname(t.name))
      require 'fileutils'
      File.mkdir_p File.dirname(t.name)
    end
    tf = File.open(t.name, 'wb')
    gz = Zlib::GzipWriter.new(tf)
    tw = Archive::Tar::Minitar::Writer.new(gz)

    files.each do |entry|
      if entry[:dir]
        tw.mkdir(entry[:name], entry)
      else
        tw.add_file_simple(entry[:name], entry) { |os|
          os.write(entry[:data])
        }
      end
    end
  ensure
    tw.close if tw
    gz.close if gz
  end
end
task :package => [ PKG_TAR ]

desc "Build the manifest file from the current set of files."
task :build_manifest do |t|
  require 'find'

  paths = []
  Find.find(".") do |path|
    next if File.directory?(path)
    next if path =~ /\.svn/
    next if path =~ /\.git/
    next if path =~ /\.hoerc/
    next if path =~ /\.swp$/
    next if path =~ %r{coverage/}
    next if path =~ /~$/
    paths << path.sub(%r{^\./}, '')
  end

  File.open("Manifest.txt", "w") do |f|
    f.puts paths.sort.join("\n")
  end

  puts paths.sort.join("\n")
end
