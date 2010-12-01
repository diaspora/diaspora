
if HAVE_GIT

namespace :git do

  # A prerequisites task that all other tasks depend upon
  task :prereqs

  desc 'Show tags from the Git repository'
  task :show_tags => 'git:prereqs' do |t|
    puts %x/git tag/
  end

  desc 'Create a new tag in the Git repository'
  task :create_tag => 'git:prereqs' do |t|
    v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
    abort "Versions don't match #{v} vs #{PROJ.version}" if v != PROJ.version

#    tag = "%s-%s" % [PROJ.name, PROJ.version]
    tag = "%s" % [ PROJ.version ]
    msg = "Creating tag for #{PROJ.name} version #{PROJ.version}"

    puts "Creating Git tag '#{tag}'"
    unless system "git tag -a -m '#{msg}' #{tag}"
      abort "Tag creation failed"
    end

#    if %x/git remote/ =~ %r/^origin\s*$/
#      unless system "git push origin #{tag}"
#        abort "Could not push tag to remote Git repository"
#      end
#    end
  end

end  # namespace :git

#task 'gem:release' => 'git:create_tag'

end  # if HAVE_GIT

# EOF
