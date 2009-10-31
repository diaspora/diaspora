require 'active_support'

port = "4000"     # preview project port eg. http://localhost:4000
site = "site"     # compiled site directory
source = "source" # source file directory

# MUST CHANGE FOR YOUR PROJECT
site_url = "http://yoursite.com"   # deployed site url
ssh_user      = "user@host.com"    # for rsync deployment
document_root = "~/document_root/" # for rsync deployment

def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

desc "list tasks"
task :default do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:default]]).to_sentence}"
  puts "(type rake -T for more detail)\n\n"
end

desc "remove files in output directory"
task :clean do
  puts "Removing output..."
  Dir["#{site}/*"].each { |f| rm_rf(f) }
end

desc "generate website in output directory"
task :generate => :clean do
  puts "Generating website..."
  system "jekyll"
  Dir["#{site}/stylesheets/*.sass"].each { |f| rm_rf(f) }
  system "compass"
  system "mv #{site}/atom.html #{site}/atom.xml"
end

def rebuild_site(relative)
  puts ">>> Change Detected to: #{relative} <<<"
  IO.popen('rake generate'){|io| print(io.readpartial(512)) until io.eof?}
  puts '>>> Update Complete <<<'
end

desc "Watch the site and regenerate when it changes"
task :watch do
  require 'fssm'
  puts ">>> Watching for Changes <<<"
  FSSM.monitor("#{File.dirname(__FILE__)}/#{source}", '**/*') do
    update {|base, relative| rebuild_site(relative)}
    delete {|base, relative| rebuild_site(relative)}
    create {|base, relative| rebuild_site(relative)}
  end
end

desc "generate and deploy website"
task :deploy => :generate do
  print "Deploying website..."
  ok_failed system("rsync -avz --delete #{site}/ #{ssh_user}:#{document_root}")
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
multitask :preview => [:generate, :start_serve] do
  system "open http://localhost:#{port}"
end


desc "Build an XML sitemap of all html files."
task :sitemap => :generate do
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