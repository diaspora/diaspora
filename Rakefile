require "rubygems"
require "bundler/setup"

## -- Rsync Deploy config -- ##
# Be sure your public key is listed in your server's ~/.ssh/authorized_keys file
ssh_user       = "user@domain.com"
document_root  = "~/website.com/"
deploy_default = "rsync"

# This will be configured for you when you run config_deploy
deploy_branch  = "gh-pages"

## -- Misc Configs, you probably have no reason to changes these -- ##

public_dir  = "public"    # compiled site directory
source_dir  = "source"    # source file directory
deploy_dir  = "_deploy"    # deploy directory (for Github pages deployment)
stash_dir   = "_stash"    # directory to stash posts for speedy generation
posts_dir   = "_posts"    # directory for blog files
themes_dir  = ".themes"    # directory for blog files
post_format = "markdown"  # file format for new posts when using the post rake task


desc "Initial setup for Octopress: copies the default theme into the path of Jekyll's generator. rake install defaults to rake install[classic] to install a different theme run rake install[some_theme_name]"
task :install, :theme do |t, args|
  # copy theme into working Jekyll directories
  theme = args.theme || 'classic'
  puts "## Copying "+theme+" theme into ./#{source_dir} ./sass and ./plugins "
  mkdir_p source_dir
  cp_r "#{themes_dir}/#{theme}/source/.", source_dir
  mkdir_p "sass"
  cp_r "#{themes_dir}/#{theme}/sass/.", "sass"
  mkdir_p "plugins"
  cp_r "#{themes_dir}/#{theme}/plugins/.", "plugins"
  mkdir_p "#{source_dir}/#{posts_dir}"
  mkdir_p public_dir
end

#######################
# Working with Jekyll #
#######################

desc "Generate jekyll site"
task :generate do
  puts "## Generating Site with Jekyll"
  system "jekyll"
end

desc "Watch the site and regenerate when it changes"
task :watch do
  system "trap 'kill $jekyllPid $compassPid' Exit; jekyll --auto & jekyllPid=$!; compass watch & compassPid=$!; wait"
end

desc "preview the site in a web browser"
task :preview do
  system "trap 'kill $jekyllPid $compassPid' Exit; jekyll --auto --server & jekyllPid=$!; compass watch & compassPid=$!; wait"
end

# usage rake post[my-new-post] or rake post['my new post'] or rake post (defaults to "new-post")
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :post, :filename do |t, args|
  require './_plugins/titlecase.rb'
  args.with_defaults(:filename => 'new-post')
  open("#{source_dir}/_posts/#{Time.now.strftime('%Y-%m-%d')}-#{args.filename.downcase.gsub(/[ _]/, '-')}.#{post_format}", 'w') do |post|
    system "mkdir -p #{source_dir}/#{posts_dir}";
    post.puts "---"
    post.puts "title: #{args.filename.gsub(/[-_]/, ' ').titlecase}"
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "layout: post"
    post.puts "categories: []"
    post.puts "---"
  end
end

# usage rake isolate[my-post]
desc "Move all other posts than the one currently being worked on to a temporary stash location (stash) so regenerating the site happens much quicker."
task :isolate, :filename do |t, args|
  stash_dir = "#{source_dir}/#{stash_dir}"
  FileUtils.mkdir(stash_dir) unless File.exist?(stash_dir)
  Dir.glob("#{source_dir}/#{posts_dir}/*.*") do |post|
    FileUtils.mv post, stash_dir unless post.include?(args.filename)
  end
end

desc "Move all stashed posts back into the posts directory, ready for site generation."
task :integrate do
  FileUtils.mv Dir.glob("#{source_dir}/#{stash_dir}/*.*"), "#{source_dir}/#{posts_dir}/"
end

desc "Clean out caches: _code_cache, _gist_cache, .sass-cache"
task :clean do
  system "rm -rf _code_cache/** _gist_cache/** .sass-cache/**"
end

##############
# Deploying  #
##############

desc "Default deploy task"
task :deploy => "#{deploy_default}" do
end

desc "Deploy website via rsync"
task :rsync do
  puts "## Deploying website via Rsync"
  ok_failed system("rsync -avz --delete #{public_dir}/ #{ssh_user}:#{document_root}")
end

desc "deploy public directory to github pages"
task :push do
  puts "## Deploying branch to Github Pages "
  (Dir["#{deploy_dir}/*"]).each { |f| rm_rf(f) }
  system "cp -R #{public_dir}/ #{deploy_dir}"
  puts "\n## copying #{public_dir} to #{deploy_dir}"
  cd "#{deploy_dir}" do
    system "git add ."
    system "git add -u"
    puts "\n## Commiting: Site updated at #{Time.now.utc}"
    message = "Site updated at #{Time.now.utc}"
    system "git commit -m '#{message}'"
    puts "\n## Pushing generated #{deploy_dir} website"
    system "git push origin #{deploy_branch}"
    puts "\n## Github Pages deploy complete"
  end
end

desc "setup _deploy folder and deploy branch"
task :config_deploy, :branch do |t, args|
  puts "!! Please provide a deploy branch, eg. rake init_deploy[gh-pages] !!" unless args.branch
  puts "## Creating a clean #{args.branch} branch in ./#{deploy_dir} for Github pages deployment"
  cd "#{deploy_dir}" do
    system "git symbolic-ref HEAD refs/heads/#{args.branch}"
    system "rm .git/index"
    system "git clean -fdx"
    system "echo 'My Octopress Page is coming soon &hellip;' > index.html"
    system "git add ."
    system "git commit -m 'Octopress init'"
    rakefile = IO.read(__FILE__)
    rakefile.sub!(/deploy_branch(\s*)=(\s*)(["'])[\w-]*["']/, "deploy_branch\\1=\\2\\3#{args.branch}\\3")
    rakefile.sub!(/deploy_default(\s*)=(\s*)(["'])[\w-]*["']/, "deploy_default\\1=\\2\\3push\\3")
    File.open(__FILE__, 'w') do |f|
      f.write rakefile
    end
  end
  puts "## Deployment configured. Now you can deploy to the #{args.branch} branch with `rake deploy` ##"
end

def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

desc "list tasks"
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).to_sentence}"
  puts "(type rake -T for more detail)\n\n"
end
