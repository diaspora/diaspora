namespace :spec do
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.libs = %w[lib spec]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--color', '--format', 'specdoc']
    
    t.rcov = RCOV_ENABLED
    t.rcov_opts = [
      '--exclude', 'spec',
      '--exclude', '1\\.8\\/gems',
      '--exclude', '1\\.9\\/gems',
      '--exclude', 'addressable\\/idna\\.rb', # unicode tables too big
    ]
  end

  Spec::Rake::SpecTask.new(:normal) do |t|
    t.libs = %w[lib spec]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--color', '--format', 'specdoc']
    t.rcov = false
  end

  desc "Generate HTML Specdocs for all specs"
  Spec::Rake::SpecTask.new(:specdoc) do |t|
    specdoc_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'specdoc'))
    Dir.mkdir(specdoc_path) if !File.exist?(specdoc_path)

    output_file = File.join(specdoc_path, 'index.html')
    t.libs = %w[lib spec]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ["--format", "\"html:#{output_file}\"", "--diff"]
    t.fail_on_error = false
  end

  namespace :rcov do
    desc "Browse the code coverage report."
    task :browse => "spec:rcov" do
      require "launchy"
      Launchy::Browser.run("coverage/index.html")
    end
  end
end

desc "Alias to spec:normal"
task "spec" => "spec:normal"

task "clobber" => ["spec:clobber_rcov"]
