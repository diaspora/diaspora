#!/usr/bin/env ruby
require 'rbconfig'
require 'find'
require 'ftools'
require 'tempfile'
include Config

LIBDIR      = "lib"
LIBDIR_MODE = 0644

BINDIR      = "bin"
BINDIR_MODE = 0755


$srcdir            = CONFIG["srcdir"]
$version           = CONFIG["MAJOR"]+"."+CONFIG["MINOR"]
$libdir            = File.join(CONFIG["libdir"], "ruby", $version)
$archdir           = File.join($libdir, CONFIG["arch"])
$site_libdir       = $:.find {|x| x =~ /site_ruby$/}
$bindir            = CONFIG["bindir"] || CONFIG['BINDIR']
$ruby_install_name = CONFIG['ruby_install_name'] || CONFIG['RUBY_INSTALL_NAME'] || 'ruby'
$ruby_ext          = CONFIG['EXEEXT'] || ''
$ruby              = File.join($bindir, ($ruby_install_name + $ruby_ext))

if !$site_libdir
  $site_libdir = File.join($libdir, "site_ruby")
elsif $site_libdir !~ %r/#{Regexp.quote($version)}/
  $site_libdir = File.join($site_libdir, $version)
end

def install_rb(srcdir=nil, destdir=nil, mode=nil, bin=nil)
#{{{
  path   = []
  dir    = []
  Find.find(srcdir) do |f|
    next unless FileTest.file?(f)
    next if (f = f[srcdir.length+1..-1]) == nil
    next if (/CVS$/ =~ File.dirname(f))
    next if f =~ %r/\.lnk/
    path.push f
    dir |= [File.dirname(f)]
  end
  for f in dir
    next if f == "."
    next if f == "CVS"
    File::makedirs(File.join(destdir, f))
  end
  for f in path
    next if (/\~$/ =~ f)
    next if (/^\./ =~ File.basename(f))
    unless bin
      File::install(File.join(srcdir, f), File.join(destdir, f), mode, true)
    else
      from = File.join(srcdir, f)
      to = File.join(destdir, f)
      shebangify(from) do |sf|
        $deferr.print from, " -> ", File::catname(from, to), "\n"
        $deferr.printf "chmod %04o %s\n", mode, to 
        File::install(sf, to, mode, false)
      end
    end
  end
#}}}
end
def shebangify f
#{{{
  open(f) do |fd|
    buf = fd.read 42 
    if buf =~ %r/^\s*#\s*!.*ruby/o
      ftmp = Tempfile::new("#{ $$ }_#{ File::basename(f) }")
      begin
        fd.rewind
        ftmp.puts "#!#{ $ruby  }"
        while((buf = fd.read(8192)))
          ftmp.write buf
        end
        ftmp.close
        yield ftmp.path
      ensure
        ftmp.close!
      end
    else
      yield f
    end
  end
#}}}
end
def ARGV.switch
#{{{
  return nil if self.empty?
  arg = self.shift
  return nil if arg == '--'
  if arg =~ /^-(.)(.*)/
    return arg if $1 == '-'
    raise 'unknown switch "-"' if $2.index('-')
    self.unshift "-#{$2}" if $2.size > 0
    "-#{$1}"
  else
    self.unshift arg
    nil
  end
#}}}
end
def ARGV.req_arg
#{{{
  self.shift || raise('missing argument')
#}}}
end
def linkify d, linked = []
#--{{{
  if test ?d, d
    versioned = Dir[ File::join(d, "*-[0-9].[0-9].[0-9].rb") ]
    versioned.each do |v| 
      src, dst = v, v.gsub(%r/\-[\d\.]+\.rb$/, '.rb')
      lnk = nil
      begin
        if test ?l, dst
          lnk = "#{ dst }.lnk"
          puts "#{ dst } -> #{ lnk }"
          File::rename dst, lnk
        end
        unless test ?e, dst
          puts "#{ src } -> #{ dst }"
          File::copy src, dst 
          linked << dst
        end
      ensure
        if lnk
          at_exit do
            puts "#{ lnk } -> #{ dst }"
            File::rename lnk, dst
          end
        end
      end
    end
  end
  linked
#--}}}
end


#
# main program
#

libdir = $site_libdir
bindir = $bindir
no_linkify = false
linked = nil
help = false

usage = <<-usage
  #{ File::basename $0 }
    -d, --destdir    <destdir>
    -l, --libdir     <libdir>
    -b, --bindir     <bindir>
    -r, --ruby       <ruby>
    -n, --no_linkify
    -s, --sudo
    -h, --help
usage

begin
  while switch = ARGV.switch
    case switch
    when '-d', '--destdir'
      libdir = ARGV.req_arg
    when '-l', '--libdir'
      libdir = ARGV.req_arg
    when '-b', '--bindir'
      bindir = ARGV.req_arg
    when '-r', '--ruby'
      $ruby = ARGV.req_arg
    when '-n', '--no_linkify'
      no_linkify = true
    when '-s', '--sudo'
      sudo = 'sudo' 
    when '-h', '--help'
      help = true
    else
      raise "unknown switch #{switch.dump}"
    end
  end
rescue
  STDERR.puts $!.to_s
  STDERR.puts usage
  exit 1
end    

if help
  STDOUT.puts usage
  exit
end

unless no_linkify
  linked = linkify('lib') + linkify('bin')
end

system "#{ $ruby } extconf.rb && make && #{ sudo } make install" if test(?s, 'extconf.rb')

install_rb(LIBDIR, libdir, LIBDIR_MODE)
install_rb(BINDIR, bindir, BINDIR_MODE, bin=true)

if linked
  linked.each{|path| File::rm_f path}
end
