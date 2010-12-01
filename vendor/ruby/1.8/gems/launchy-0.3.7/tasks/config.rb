require 'configuration'

require 'rake'
require 'tasks/utils'

#-----------------------------------------------------------------------
# General project configuration
#-----------------------------------------------------------------------
Configuration.for('project') {
  name          "launchy"
  version       Launchy::Version.to_s
  author        "Jeremy Hinegardner"
  email         "jeremy at copiousfreetime dot org"
  homepage      "http://copiousfreetime.rubyforge.org/launchy/"
  description   Utils.section_of("README", "description")
  summary       description.split(".").first
  history       "HISTORY"
  license       FileList["LICENSE"]
  readme        "README"
}

#-----------------------------------------------------------------------
# Packaging 
#-----------------------------------------------------------------------
Configuration.for('packaging') {
  # files in the project 
  proj_conf = Configuration.for('project')
  files {
    bin       FileList["bin/*"]
    ext       FileList["ext/*.{c,h,rb}"]
    examples  FileList["examples/*.rb"]
    lib       FileList["lib/**/*.rb"]
    test      FileList["spec/**/*.rb", "test/**/*.rb"]
    data      FileList["data/**/*", "spec/**/*.yml"]
    tasks     FileList["tasks/**/*.r{ake,b}"]
    rdoc      FileList[proj_conf.readme, proj_conf.history,
                       proj_conf.license] + lib + FileList["ext/*.c"]
    all       bin + examples + ext + lib + test + data + rdoc + tasks  + FileList["Rakefile"]
  }

  # ways to package the results
  formats {
    tgz true
    zip true
    rubygem Configuration::Table.has_key?('gem')
  }
}

#-----------------------------------------------------------------------
# Gem packaging
#-----------------------------------------------------------------------
Configuration.for("gem") {
  spec "gemspec.rb"
  Configuration.for('packaging').files.all << spec
}

#-----------------------------------------------------------------------
# Testing
#   - change mode to 'testunit' to use unit testing
#-----------------------------------------------------------------------
Configuration.for('test') {
  mode      "spec"
  files     Configuration.for("packaging").files.test
  options   %w[ --format specdoc --color ]
  ruby_opts %w[ -w ]
}

#-----------------------------------------------------------------------
# Rcov 
#-----------------------------------------------------------------------
Configuration.for('rcov') {
  output_dir  "coverage"
  libs        %w[ lib ]
  rcov_opts   %w[ --html ]
  ruby_opts   %w[ -w ]
  test_files  Configuration.for('packaging').files.test
}

#-----------------------------------------------------------------------
# Rdoc 
#-----------------------------------------------------------------------
Configuration.for('rdoc') {
  files       Configuration.for('packaging').files.rdoc
  main_page   files.first
  title       Configuration.for('project').name
  options     %w[ --line-numbers --inline-source ]#-f darkfish ]
  output_dir  "doc"
}

#-----------------------------------------------------------------------
# Extension
#-----------------------------------------------------------------------
Configuration.for('extension') {
  configs   Configuration.for('packaging').files.ext.find_all { |x| %w[ mkrf_conf.rb extconf.rb ].include?(File.basename(x)) }
}

#-----------------------------------------------------------------------
# Rubyforge 
#-----------------------------------------------------------------------
Configuration.for('rubyforge') {
  project       "copiousfreetime"
  user          "jjh"
  host          "rubyforge.org"
  rdoc_location "#{user}@#{host}:/var/www/gforge-projects/#{project}/launchy"
}


