require 'rbconfig'
require 'find'
require 'ftools'

include Config

$ruby = CONFIG['ruby_install_name']

##
# Install a binary file. We patch in on the way through to
# insert a #! line. If this is a Unix install, we name
# the command (for example) 'rake' and let the shebang line
# handle running it. Under windows, we add a '.rb' extension
# and let file associations to their stuff
#

def installBIN(from, opfile)

  tmp_dir = nil
  for t in [".", "/tmp", "c:/temp", $bindir]
    stat = File.stat(t) rescue next
    if stat.directory? and stat.writable?
      tmp_dir = t
      break
    end
  end

  fail "Cannot find a temporary directory" unless tmp_dir
  tmp_file = File.join(tmp_dir, "_tmp")
    
  File.open(from) do |ip|
    File.open(tmp_file, "w") do |op|
      ruby = File.join($realbindir, $ruby)
      op.puts "#!#{ruby} -w"
      op.write ip.read
    end
  end

  opfile += ".rb" if CONFIG["target_os"] =~ /mswin/i
  File::install(tmp_file, File.join($bindir, opfile), 0755, true)
  File::unlink(tmp_file)
end

$sitedir = CONFIG["sitelibdir"]
unless $sitedir
  version = CONFIG["MAJOR"]+"."+CONFIG["MINOR"]
  $libdir = File.join(CONFIG["libdir"], "ruby", version)
  $sitedir = $:.find {|x| x =~ /site_ruby/}
  if !$sitedir
    $sitedir = File.join($libdir, "site_ruby")
  elsif $sitedir !~ Regexp.quote(version)
    $sitedir = File.join($sitedir, version)
  end
end

$bindir =  CONFIG["bindir"]

$realbindir = $bindir

bindir = CONFIG["bindir"]
if (destdir = ENV['DESTDIR'])
  $bindir  = destdir + $bindir
  $sitedir = destdir + $sitedir
  
  File::makedirs($bindir)
  File::makedirs($sitedir)
end

rake_dest = File.join($sitedir, "rake")
File::makedirs(rake_dest, true)
File::chmod(0755, rake_dest)

# The library files

files = Dir.chdir('lib') { Dir['**/*.rb'] }

for fn in files
  fn_dir = File.dirname(fn)
  target_dir = File.join($sitedir, fn_dir)
  if ! File.exist?(target_dir)
    File.makedirs(target_dir)
  end
  File::install(File.join('lib', fn), File.join($sitedir, fn), 0644, true)
end

# and the executable

installBIN("bin/rake", "rake")
