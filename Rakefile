require 'active_support'

site_url  = "http://yoursite.com"   # deployed site url for sitemap.xml generator
port      = "4000"     # preview project port eg. http://localhost:4000
site      = "site"     # compiled site directory
source    = "source" # source file directory

## -- Rsync Deploy config -- ##
ssh_user      = "user@host.com"    # for rsync deployment
document_root = "~/document_root/" # for rsync deployment
## ---- ##

## -- Github Pages deploy config -- ##
# Read http://pages.github.com for guidance
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

## if you're deploying with github, change the default deploy to deploy_github
desc "default deploy task"
task :deploy => :deploy_rsync do
end

desc "generate website in output directory"
task :default => [:generate_site, :generate_style] do
  puts ">>> Site Generating Complete! <<<\n\n"
end

# usage rake post[my-new-post] or rake post['my new post'] or rake post (defaults to "new-post")
desc "Begin a new post in #{source}/_posts"
task :post, :filename do |t, args|
  args.with_defaults(:filename => 'new-post')
  #system "touch #{source}/_posts/#{Time.now.strftime('%Y-%m-%d_%H-%M')}-#{args.filename}.markdown"
  open("#{source}/_posts/#{Time.now.strftime('%Y-%m-%d_%H-%M')}-#{args.filename.gsub(/[ _]/, '-')}.markdown", 'w') do |post|
    post.puts "---"
    post.puts "title: \"#{args.filename.gsub(/[-_]/, ' ').titlecase}\""
    post.puts "---"
  end
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
  system "compass"
end

desc "Generate site files only"
task :generate_site => [:clean, :generate_style] do
  puts "\n\n>>> Generating site files <<<"
  system "jekyll --pygments"
  system "mv #{site}/atom.html #{site}/atom.xml"
end

def rebuild_site(relative)
  puts "\n\n>>> Change Detected to: #{relative} <<<"
  IO.popen('rake generate_site'){|io| print(io.readpartial(512)) until io.eof?}
  puts '>>> Update Complete <<<'
end

def rebuild_style(relative)
  puts "\n\n>>> Change Detected to: #{relative} <<<"
  IO.popen('rake generate_style'){|io| print(io.readpartial(512)) until io.eof?}
  puts '>>> Update Complete <<<'
end

desc "Watch the site and regenerate when it changes"
task :watch do
  require 'fssm'
  puts ">>> Watching for Changes <<<"
  FSSM.monitor do
    path "#{File.dirname(__FILE__)}/#{source}" do
      update {|base, relative| rebuild_site(relative)}
      delete {|base, relative| rebuild_site(relative)}
      create {|base, relative| rebuild_site(relative)}
    end
    path "#{File.dirname(__FILE__)}/stylesheets" do
      glob '**/*.sass'
      update {|base, relative| rebuild_style(relative)}
      delete {|base, relative| rebuild_style(relative)}
      create {|base, relative| rebuild_style(relative)}
    end
  end
end

desc "generate and deploy website via rsync"
multitask :deploy_rsync => [:default, :clean_debug] do
  puts ">>> Deploying website to #{site_url} <<<"
  ok_failed system("rsync -avz --delete #{site}/ #{ssh_user}:#{document_root}")
end

desc "generate and deploy website to github user pages"
multitask :deploy_github => [:default, :clean_debug] do
  puts ">>> Deploying #{deploy_branch} branch to Github Pages <<<"
  require 'git'
  repo = Git.open('.')
  puts "\n>>> Checking out #{deploy_branch} branch <<<\n"
  repo.branch("#{deploy_branch}").checkout
  (Dir["*"] - [site]).each { |f| rm_rf(f) }
  Dir["#{site}/*"].each {|f| mv(f, ".")}
  rm_rf(site)
  puts "\n>>> Moving generated site files <<<\n"
  Dir["**/*"].each {|f| repo.add(f) }
  repo.status.deleted.each {|f, s| repo.remove(f)}
  puts "\n>>> Commiting: Site updated at #{Time.now.utc} <<<\n"
  message = ENV["MESSAGE"] || "Site updated at #{Time.now.utc}"
  repo.commit(message)
  puts "\n>>> Pushing generated site to #{deploy_branch} branch <<<\n"
  repo.push
  puts "\n>>> Github Pages deploy complete <<<\n"
  repo.branch("#{source_branch}").checkout
end

desc "start up an instance of serve on the output files"
task :start_serve => :stop_serve do
  cd "#{site}" do
    print "Starting serve..."
    ok_failed system("serve #{port} > /dev/null 2>&1 &")
  end
end

desc "stop all instances of serve"
task :stop_serve do
  pid = `ps auxw | awk '/bin\\/serve\\ #{port}/ { print $2 }'`.strip
  if pid.empty?
    puts "Serve is not running"
  else
    print "Stoping serve..."
    ok_failed system("kill -9 #{pid}")
  end
end

desc "preview the site in a web browser"
multitask :preview => [:default, :start_serve] do
  system "open http://localhost:#{port}"
end


desc "Build an XML sitemap of all html files."
task :sitemap => :default do
  html_files = FileList.new("#{site}/**/*.html").map{|f| f[("#{site}".size)..-1]}.map do |f|
    if f.ends_with?("index.html")
      f[0..(-("index.html".size + 1))]
    else
      f
    end
  end.sort_by{|f| f.size}
  open("#{site}/sitemap.xml", 'w') do |sitemap|
    sitemap.puts %Q{<?xml version="1.0" encoding="UTF-8"?>}
    sitemap.puts %Q{<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">}
    html_files.each do |f|
      priority = case f
      when %r{^/$}
        1.0
      when %r{^/blog}
        0.9
      else
        0.8
      end
      sitemap.puts %Q{  <url>}
      sitemap.puts %Q{    <loc>#{site_url}#{f}</loc>}
      sitemap.puts %Q{    <lastmod>#{Time.to_s('%Y-%m-%d')}</lastmod>}
      sitemap.puts %Q{    <changefreq>weekly</changefreq>}
      sitemap.puts %Q{    <priority>#{priority}</priority>}
      sitemap.puts %Q{  </url>}
    end
    sitemap.puts %Q{</urlset>}
    puts "Created #{site}/sitemap.xml"
  end
end