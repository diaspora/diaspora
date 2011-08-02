require "rake/rdoctask"

namespace :doc do
  desc "Generate RDoc documentation"
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = "doc"
    rdoc.title    = "#{PKG_NAME}-#{PKG_VERSION} Documentation"
    rdoc.options << "--line-numbers" << "--inline-source" <<
      "--accessor" << "cattr_accessor=object" << "--charset" << "utf-8"
    rdoc.template = "#{ENV["template"]}.rb" if ENV["template"]
    rdoc.rdoc_files.include("README", "CHANGELOG", "LICENSE")
    rdoc.rdoc_files.include("lib/**/*.rb")
  end

  desc "Generate ri locally for testing"
  task :ri do
    sh "rdoc --ri -o ri ."
  end

  desc "Remove ri products"
  task :clobber_ri do
    rm_r "ri" rescue nil
  end
end

desc "Alias to doc:rdoc"
task "doc" => "doc:rdoc"

task "clobber" => ["doc:clobber_rdoc", "doc:clobber_ri"]
