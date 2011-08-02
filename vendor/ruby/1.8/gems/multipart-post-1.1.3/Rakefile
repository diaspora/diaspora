require 'bundler/setup'

begin
  require 'hoe'
  require 'multipart_post'

  Hoe.plugin :rubyforge
  hoe = Hoe.spec("multipart-post") do |p|
    p.version = MultipartPost::VERSION
    p.rubyforge_name = "caldersphere"
    p.author = "Nick Sieger"
    p.url = "http://github.com/nicksieger/multipart-post"
    p.email = "nick@nicksieger.com"
    p.description = "Use with Net::HTTP to do multipart form posts.  IO values that have #content_type, #original_filename, and #local_path will be posted as a binary file."
    p.summary = "Creates a multipart form post accessory for Net::HTTP."
  end
  hoe.spec.dependencies.delete_if { |dep| dep.name == "hoe" || dep.name == "rubyforge" }

  task :gemspec do
    File.open("#{hoe.name}.gemspec", "w") {|f| f << hoe.spec.to_ruby }
  end
  task :package => :gemspec
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
end
