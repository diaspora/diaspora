require "rubygems"
require "bundler/setup"

site        = "public"    # compiled site directory
source      = "source"    # source file directory
stash       = "_stash"    # directory to stash posts for speedy generation
posts       = "_posts"    # directory for blog files
post_format = "markdown"  # file format for new posts when using the post rake task

## -- Rsync Deploy config -- ##
# Be sure your public key is listed in your server's ~/.ssh/authorized_keys file
ssh_user      = "mathisweb@imathis.com"
document_root = "~/dev.octopress.org/"

## -- Github Pages deploy config -- ##
# Read http://pages.github.com for guidance
# You can deploy to github pages with `rake push_github` or change the default push task to :push_github
source_branch = "source" # this compiles to your deploy branch
deploy_branch = "master" # For user pages, use "master" for project pages use "gh-pages"


desc "Initial setup for Octopress: copies the default theme into the path of Jekyll's generator. rake install defaults to rake install[classic] to install a different theme run rake install[some_theme_name]"
task :install, :theme do |t, args|
  # copy theme into working Jekyll directories
  theme = args.theme || 'classic'
  puts "## Copying "+theme+" theme to Jekyll paths"
  system "mkdir -p #{source}; cp -R themes/"+theme+"/source/ #{source}/"
  system "mkdir -p sass; cp -R themes/"+theme+"/sass/ sass/"
  system "mkdir -p _plugins; cp -R themes/"+theme+"/_plugins/ _plugins/"
  system "mkdir -p #{source}/#{posts}";
  puts "## Layouts, images, and javascritps from the #{theme} theme have been installed into ./#{source}"
  puts "## Sass stylesheet sources from the #{theme} theme have been installed into ./sass"
  puts "## Plugins from the #{theme} theme have been installed into ./_plugins"
end

#######################
# Working with Jekyll #
#######################

desc "Watch the site and regenerate when it changes"
task :watch do
  system "trap 'kill $jekyllPid $compassPid' Exit; jekyll --auto & jekyllPid=$!; compass watch & compassPid=$!; wait"
end

desc "preview the site in a web browser"
task :preview do
  system "trap 'kill $jekyllPid $compassPid' Exit; jekyll --auto --server & jekyllPid=$!; compass watch & compassPid=$!; wait"
end

# usage rake post[my-new-post] or rake post['my new post'] or rake post (defaults to "new-post")
desc "Begin a new post in #{source}/_posts"
task :post, :filename do |t, args|
  require './_plugins/titlecase.rb'
  args.with_defaults(:filename => 'new-post')
  open("#{source}/_posts/#{Time.now.strftime('%Y-%m-%d')}-#{args.filename.downcase.gsub(/[ _]/, '-')}.#{post_format}", 'w') do |post|
    system "mkdir -p #{source}/#{posts}";
    post.puts "---"
    post.puts "title: #{args.filename.gsub(/[-_]/, ' ').titlecase}"
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

desc "Clean out caches: _code_cache, _gist_cache, .sass-cache"
task :clean do
  system "rm -rf _code_cache/** _gist_cache/** .sass-cache/**"
end

##############
# Deploying  #
##############

## if you're deploying with github, change the default deploy to push_github
desc "default push task"
task :push => [:push_rsync] do
end

desc "Generate and deploy task"
multitask :deploy => [:integrate, :generate, :push] do
end

desc "Generate jekyll site"
task :generate do
  puts "## Generating Site with Jekyll"
  system "jekyll"
end

def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

desc "Deploy website via rsync"
task :push_rsync do
  puts "## Deploying website via Rsync"
  ok_failed system("rsync -avz --delete #{site}/ #{ssh_user}:#{document_root}")
end

desc "deploy website to github pages"
multitask :push_github do
  puts "## Deploying #{deploy_branch} branch to Github Pages "
  require 'git'
  repo = Git.open('.')
  puts "\n## Checking out #{deploy_branch} branch \n"
  repo.branch("#{deploy_branch}").checkout
  (Dir["*"] - ["#{site}"]).each { |f| rm_rf(f) }
  Dir["#{site}/*"].each {|f| mv(f, ".")}
  rm_rf("#{site}")
  puts "\n## Moving generated /#{site} files \n"
  Dir["**/*"].each {|f| repo.add(f) }
  repo.status.deleted.each {|f, s| repo.remove(f)}
  puts "\n## Commiting: Site updated at #{Time.now.utc} \n"
  message = ENV["MESSAGE"] || "Site updated at #{Time.now.utc}"
  repo.commit(message)
  puts "\n## Pushing generated /#{site} files to #{deploy_branch} branch\n"
  repo.push
  puts "\n## Github Pages deploy complete\n"
  repo.branch("#{source_branch}").checkout
end



desc "list tasks"
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).to_sentence}"
  puts "(type rake -T for more detail)\n\n"
end
