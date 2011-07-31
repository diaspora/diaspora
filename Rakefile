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

public_dir   = "public"    # compiled site directory
source_dir   = "source"    # source file directory
deploy_dir   = "_deploy"   # deploy directory (for Github pages deployment)
stash_dir    = "_stash"    # directory to stash posts for speedy generation
posts_dir    = "_posts"    # directory for blog files
themes_dir   = ".themes"   # directory for blog files
new_post_ext = "markdown"  # default new post file extension when using the new_post task
new_page_ext = "markdown"  # default new page file extension when using the new_page task


desc "Initial setup for Octopress: copies the default theme into the path of Jekyll's generator. Rake install defaults to rake install[classic] to install a different theme run rake install[some_theme_name]"
task :install, :theme do |t, args|
  # copy theme into working Jekyll directories
  theme = args.theme || 'classic'
  puts "## Copying "+theme+" theme into ./#{source_dir} and ./sass"
  mkdir_p source_dir
  cp_r "#{themes_dir}/#{theme}/source/.", source_dir
  mkdir_p "sass"
  cp_r "#{themes_dir}/#{theme}/sass/.", "sass"
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

# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :new_post, :title do |t, args|
  require './plugins/titlecase.rb'
  args.with_defaults(:title => 'new-post')
  title = args.title
  filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.downcase.gsub(/&/,'and').gsub(/[,'":\?!\(\)\[\]]/,'').gsub(/[\W\.]/, '-').gsub(/-+$/,'')}.#{new_post_ext}"
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    system "mkdir -p #{source_dir}/#{posts_dir}";
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;').titlecase}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "---"
  end
end

# usage rake new_page[my-new-page] or rake new_page[my-new-page.html] or rake new_page (defaults to "new-page.markdown")
desc "Create a new page in #{source_dir}/(filename)/index.#{new_page_ext}"
task :new_page, :filename do |t, args|
  require './plugins/titlecase.rb'
  args.with_defaults(:filename => 'new-page')
  page_dir = source_dir
  if args.filename =~ /(^.+\/)?([\w_-]+)(\.)?(.+)?/
    page_dir += $4 ? "/#{$1}" : "/#{$1}#{$2}/"
    name = $4 ? $2 : "index"
    extension = $4 || "#{new_page_ext}"
    filename = "#{name}.#{extension}"
    mkdir_p page_dir
    file = page_dir + filename
    puts "Creating new page: #{file}"
    open(file, 'w') do |page|
      page.puts "---"
      page.puts "layout: page"
      page.puts "title: \"#{$2.gsub(/[-_]/, ' ').titlecase}\""
      page.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
      page.puts "comments: true"
      page.puts "sharing: true"
      page.puts "footer: true"
      page.puts "---"
    end
  else
    puts "Syntax error: #{args.filename} contains unsupported characters"
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

desc "Move sass to sass.old, install sass theme updates, replace sass/custom with sass.old/custom"
task :update_style, :theme do |t, args|
  theme = args.theme || 'classic'
  if File.directory?("sass.old")
    puts "removed existing sass.old directory"
    system "rm -r sass.old"
  end
  system "mv sass sass.old"
  puts "## Moved styles into sass.old/"
  system "mkdir -p sass; cp -R #{themes_dir}/"+theme+"/sass/ sass/"
  cp_r "sass.old/custom/.", "sass/custom"
  puts "## Updated Sass ##"
end

desc "Move source to source.old, install source theme updates, replace source/_includes/navigation.html with source.old's navigation"
task :update_source, :theme do |t, args|
  theme = args.theme || 'classic'
  if File.directory?("#{source_dir}.old")
    puts "removed existing #{source_dir}.old directory"
    system "rm -r #{source_dir}.old"
  end
  system "mv #{source_dir} #{source_dir}.old"
  puts "moved #{source_dir} into #{source_dir}.old/"
  system "mkdir -p #{source_dir}; cp -R #{themes_dir}/"+theme+"/source/. #{source_dir}"
  system "cp -Rn #{source_dir}.old/. #{source_dir}"
  system "cp -Rf #{source_dir}.old/_includes/custom/. #{source_dir}/_includes/custom/"
  puts "## Updated #{source_dir} ##"
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
  system "cp -R #{public_dir}/* #{deploy_dir}"
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

desc "Update configurations to support publishing to root or sub directory"
task :set_root_dir, :dir do |t, args|
  puts ">>> !! Please provide a directory, eg. rake config_dir[publishing/subdirectory]" unless args.dir
  if args.dir
    if args.dir == "/"
      dir = ""
    else
      dir = "/" + args.dir.sub(/(\/*)(.+)/, "\\2").sub(/\/$/, '');
    end
    rakefile = IO.read(__FILE__)
    rakefile.sub!(/public_dir(\s*)=(\s*)(["'])[\w\-\/]*["']/, "public_dir\\1=\\2\\3public#{dir}\\3")
    File.open(__FILE__, 'w') do |f|
      f.write rakefile
    end
    compass_config = IO.read('config.rb')
    compass_config.sub!(/http_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_path\\1=\\2\\3#{dir}/\\3")
    compass_config.sub!(/http_images_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_images_path\\1=\\2\\3#{dir}/images\\3")
    compass_config.sub!(/http_fonts_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_fonts_path\\1=\\2\\3#{dir}/fonts\\3")
    compass_config.sub!(/css_dir(\s*)=(\s*)(["'])[\w\-\/]*["']/, "css_dir\\1=\\2\\3public#{dir}/stylesheets\\3")
    File.open('config.rb', 'w') do |f|
      f.write compass_config
    end
    jekyll_config = IO.read('_config.yml')
    jekyll_config.sub!(/^destination:.+$/, "destination: public#{dir}")
    jekyll_config.sub!(/^subscribe_rss:\s*\/.+$/, "subscribe_rss: #{dir}/atom.xml")
    jekyll_config.sub!(/^root:.*$/, "root: /#{dir.sub(/^\//, '')}")
    File.open('_config.yml', 'w') do |f|
      f.write jekyll_config
    end
    rm_rf public_dir
    mkdir_p "#{public_dir}#{dir}"
    puts "## Site's root directory is now '/#{dir.sub(/^\//, '')}' ##"
  end
end

desc "Setup _deploy folder and deploy branch"
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
