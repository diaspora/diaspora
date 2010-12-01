
if PROJ.rubyforge.name.valid? && HAVE_RUBYFORGE

require 'rubyforge'
require 'rake/contrib/sshpublisher'

namespace :gem do
  desc 'Package and upload to RubyForge'
  task :release => [:clobber, 'gem'] do |t|
    v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
    abort "Versions don't match #{v} vs #{PROJ.version}" if v != PROJ.version
    pkg = "pkg/#{PROJ.gem._spec.full_name}"

    if $DEBUG then
      puts "release_id = rf.add_release #{PROJ.rubyforge.name.inspect}, #{PROJ.name.inspect}, #{PROJ.version.inspect}, \"#{pkg}.tgz\""
      puts "rf.add_file #{PROJ.rubyforge.name.inspect}, #{PROJ.name.inspect}, release_id, \"#{pkg}.gem\""
    end

    rf = RubyForge.new
    rf.configure rescue nil
    puts 'Logging in'
    rf.login

    c = rf.userconfig
    c['release_notes'] = PROJ.description if PROJ.description
    c['release_changes'] = PROJ.changes if PROJ.changes
    c['preformatted'] = true

    files = Dir.glob("#{pkg}*.*")

    puts "Releasing #{PROJ.name} v. #{PROJ.version}"
    rf.add_release PROJ.rubyforge.name, PROJ.name, PROJ.version, *files
  end
end  # namespace :gem


namespace :doc do
  desc "Publish RDoc to RubyForge"
  task :release => %w(doc:clobber_rdoc doc:rdoc) do
    config = YAML.load(
        File.read(File.expand_path('~/.rubyforge/user-config.yml'))
    )

    host = "#{config['username']}@rubyforge.org"
    remote_dir = "/var/www/gforge-projects/#{PROJ.rubyforge.name}/"
    remote_dir << PROJ.rdoc.remote_dir if PROJ.rdoc.remote_dir
    local_dir = PROJ.rdoc.dir

    Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
  end
end  # namespace :doc

end  # if HAVE_RUBYFORGE

# EOF
