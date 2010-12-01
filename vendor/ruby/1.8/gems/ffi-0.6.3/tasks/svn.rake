
if HAVE_SVN

unless PROJ.svn.root
  info = %x/svn info ./
  m = %r/^Repository Root:\s+(.*)$/.match(info)
  PROJ.svn.root = (m.nil? ? '' : m[1])
end
PROJ.svn.root = File.join(PROJ.svn.root, PROJ.svn.path) unless PROJ.svn.path.empty?

namespace :svn do

  # A prerequisites task that all other tasks depend upon
  task :prereqs

  desc 'Show tags from the SVN repository'
  task :show_tags => 'svn:prereqs' do |t|
    tags = %x/svn list #{File.join(PROJ.svn.root, PROJ.svn.tags)}/
    tags.gsub!(%r/\/$/, '')
    tags = tags.split("\n").sort {|a,b| b <=> a}
    puts tags
  end

  desc 'Create a new tag in the SVN repository'
  task :create_tag => 'svn:prereqs' do |t|
    v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
    abort "Versions don't match #{v} vs #{PROJ.version}" if v != PROJ.version

    svn = PROJ.svn
    trunk = File.join(svn.root, svn.trunk)
    tag = "%s-%s" % [PROJ.name, PROJ.version]
    tag = File.join(svn.root, svn.tags, tag)
    msg = "Creating tag for #{PROJ.name} version #{PROJ.version}"

    puts "Creating SVN tag '#{tag}'"
    unless system "svn cp -m '#{msg}' #{trunk} #{tag}"
      abort "Tag creation failed" 
    end
  end

end  # namespace :svn

task 'gem:release' => 'svn:create_tag'

end  # if PROJ.svn.path

# EOF
