require "rubygems"
require "bundler"
Bundler.setup

port        = "4000"      # preview project port eg. http://localhost:4000
site        = "public"    # compiled site directory
source      = "source"    # source file directory
stash       = "_stash"    # directory to stash posts for speedy generation
posts       = "_posts"    # directory for blog files
post_format = "markdown"  # file format for new posts when using the post rake task

## -- Rsync Deploy config -- ##
ssh_user      = "user@host.com"    # for rsync deployment
document_root = "~/document_root/" # for rsync deployment
## ---- ##

## -- Github Pages deploy config -- ##
# Read http://pages.github.com for guidance
# You can deploy to github pages with `rake push_github` or change the default push task below to :push_github
# If you're not using this, you can remove it
source_branch = "source" # this compiles to your deploy branch
deploy_branch = "master" # For user pages, use "master" for project pages use "gh-pages"
## ---- ##

def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

## if you're deploying with github, change the default deploy to push_github
desc "default push task"
task :push => [:push_rsync] do
end

desc "Generate and deploy task"
task :deploy => [:integrate, :generate, :clean_debug, :push] do
end

desc "generate website in output directory"
task :generate => [:generate_site, :generate_style] do
  puts ">>> Site Generating Complete! <<<\n\n>>> Refresh your browser <<<"
end

# usage rake post[my-new-post] or rake post['my new post'] or rake post (defaults to "new-post")
desc "Begin a new post in #{source}/_posts"
task :post, :filename do |t, args|
  require './_plugins/titlecase.rb'
  args.with_defaults(:filename => 'new-post')
  open("#{source}/_posts/#{Time.now.strftime('%Y-%m-%d')}-#{args.filename.downcase.gsub(/[ _]/, '-')}.#{post_format}", 'w') do |post|
    post.puts "---"
    post.puts "title: \"#{args.filename.gsub(/[-_]/, ' ').titlecase}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "layout: post"
    post.puts "---"
  end
end

# usage rake isolate[my-post]
desc "Move all other posts than the one currently being worked on to a temporary stash location (stash) so regenerating the site happens much quicker."
task :isolate, :filename do |t, args|
  stash_dir = "#{source}/#{stash}"
  FileUtils.mkdir(stash_dir) unless File.exist?(stash_dir)
  Dir.glob("#{source}/#{posts}/*.*") do |post|
    FileUtils.mv post, stash_dir unless post.include?(args.filename)
  end
end

desc "Move all stashed posts back into the posts directory, ready for site generation."
task :integrate do
  FileUtils.mv Dir.glob("#{source}/#{stash}/*.*"), "#{source}/#{posts}/"
end

desc "list tasks"
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).to_sentence}"
  puts "(type rake -T for more detail)\n\n"
end

desc "remove files in output directory"
task :clean do
  puts ">>> Removing output <<<"
  Dir["#{site}/*"].each { |f| rm_rf(f) }
end

task :clean_debug do
  puts ">>> Removing debug pages <<<"
  Dir["#{site}/test"].each { |f| rm_rf(f) }
end

desc "Generate styles only"
task :generate_style do
  puts ">>> Generating styles <<<"
  system "compass compile"
end

desc "Generate site files only"
task :generate_site => [:clean, :generate_style] do
  puts "\n\n>>> Generating site files <<<"
  system "jekyll"
end

desc "Watch the site and regenerate when it changes"
task :watch do
  system "trap 'kill $jekyllPid $guardPid' Exit; guard & guardPid=$!; jekyll --auto & jekyllPid=$!; wait"
end

desc "generate and deploy website via rsync"
multitask :push_rsync do
  puts ">>> Deploying website via Rsync <<<"
  ok_failed system("rsync -avz --delete #{site}/ #{ssh_user}:#{document_root}")
end

desc "deploy website to github user pages"
multitask :push_github do
  puts ">>> Deploying #{deploy_branch} branch to Github Pages <<<"
  require 'git'
  repo = Git.open('.')
  puts "\n>>> Checking out #{deploy_branch} branch <<<\n"
  repo.branch("#{deploy_branch}").checkout
  (Dir["*"] - ["#{site}"]).each { |f| rm_rf(f) }
  Dir["#{site}/*"].each {|f| mv(f, ".")}
  rm_rf("#{site}")
  puts "\n>>> Moving generated /#{site} files <<<\n"
  Dir["**/*"].each {|f| repo.add(f) }
  repo.status.deleted.each {|f, s| repo.remove(f)}
  puts "\n>>> Commiting: Site updated at #{Time.now.utc} <<<\n"
  message = ENV["MESSAGE"] || "Site updated at #{Time.now.utc}"
  repo.commit(message)
  puts "\n>>> Pushing generated /#{site} files to #{deploy_branch} branch <<<\n"
  repo.push
  puts "\n>>> Github Pages deploy complete <<<\n"
  repo.branch("#{source_branch}").checkout
end

desc "start up a web server on the output files"
task :start_server => :stop_server do
  print "Starting serve..."
  system("serve #{site} #{port} > /dev/null 2>&1 &")
  sleep 1
  pid = `ps auxw | awk '/bin\\/serve #{site} #{port}/ { print $2 }'`.strip
  ok_failed !pid.empty?
  system "open http://localhost:#{port}" unless pid.empty?
end

desc "stop the web server"
task :stop_server do
  pid = `ps auxw | awk '/bin\\/serve #{site} #{port}/ { print $2 }'`.strip
  if pid.empty?
    puts "Adsf is not running"
  else
    print "Stoping adsf..."
    ok_failed system("kill -9 #{pid}")
  end
end

desc "preview the site in a web browser"
task :preview do
  system "trap 'kill $servePid $jekyllPid $guardPid' Exit; serve #{site} #{port} > /dev/null 2>&1 & servePid=$!; jekyll --auto & jekyllPid=$!; guard & guardPid=$!; compass compile; open http://localhost:#{port}; wait"
end
