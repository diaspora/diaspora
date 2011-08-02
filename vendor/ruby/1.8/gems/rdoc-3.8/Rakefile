require 'hoe'
$:.unshift 'lib'
require 'rdoc/rdoc'

Hoe.plugin :git
Hoe.plugin :isolate
Hoe.plugin :minitest
Hoe.plugin :rdoc_tags

$rdoc_rakefile = true

Hoe.spec 'rdoc' do
  developer 'Eric Hodel', 'drbrain@segment7.net'
  developer 'Dave Thomas', ''
  developer 'Phil Hagelberg', 'technomancy@gmail.com'
  developer 'Tony Strauss', 'tony.strauss@designingpatterns.com'

  self.rsync_args = '-avz'
  rdoc_locations << 'docs.seattlerb.org:/data/www/docs.seattlerb.org/rdoc/'
  rdoc_locations << 'drbrain@rubyforge.org:/var/www/gforge-projects/rdoc/'

  self.testlib = :minitest
  self.isolate_dir = 'tmp/isolate'

  require_ruby_version '>= 1.8.7'
  extra_dev_deps   << ['minitest', '~> 2']
  extra_dev_deps   << ['isolate',  '~> 3']
  extra_dev_deps   << ['ZenTest',  '~> 4'] # for autotest/isolate

  extra_rdoc_files << 'Rakefile'
  spec_extras['required_rubygems_version'] = '>= 1.3'
  spec_extras['homepage'] = 'http://docs.seattlerb.org/rdoc'
end

# These tasks expect to have the following directory structure:
#
#   git/git.rubini.us/code # Rubinius git HEAD checkout
#   svn/ruby/trunk         # ruby subversion HEAD checkout
#   svn/rdoc/trunk         # RDoc subversion HEAD checkout
#
# If you don't have this directory structure, set RUBY_PATH and/or
# RUBINIUS_PATH.

diff_options = "-urpN --exclude '*svn*' --exclude '*swp' --exclude '*rbc'"
rsync_options = "-avP --exclude '*svn*' --exclude '*swp' --exclude '*rbc' --exclude '*.rej' --exclude '*.orig'"

rubinius_dir = ENV['RUBINIUS_PATH'] || '../../../git/git.rubini.us/code'
ruby_dir = ENV['RUBY_PATH'] || '../../svn/ruby/trunk'

desc "Updates Ruby HEAD with the currently checked-out copy of RDoc."
task :update_ruby do
  sh "rsync #{rsync_options} bin/rdoc #{ruby_dir}/bin/rdoc"
  sh "rsync #{rsync_options} bin/ri #{ruby_dir}/bin/ri"
  sh "rsync #{rsync_options} lib/ #{ruby_dir}/lib"
  sh "rsync #{rsync_options} test/ #{ruby_dir}/test/rdoc"
end

desc "Diffs Ruby HEAD with the currently checked-out copy of RDoc."
task :diff_ruby do
  options = "-urpN --exclude '*svn*' --exclude '*swp' --exclude '*rbc'"

  sh "diff #{diff_options} bin/rdoc #{ruby_dir}/bin/rdoc; true"
  sh "diff #{diff_options} bin/ri #{ruby_dir}/bin/ri; true"
  sh "diff #{diff_options} lib/rdoc.rb #{ruby_dir}/lib/rdoc.rb; true"
  sh "diff #{diff_options} lib/rdoc #{ruby_dir}/lib/rdoc; true"
  sh "diff #{diff_options} test #{ruby_dir}/test/rdoc; true"
end

desc "Updates Rubinius HEAD with the currently checked-out copy of RDoc."
task :update_rubinius do
  sh "rsync #{rsync_options} bin/rdoc #{rubinius_dir}/lib/bin/rdoc.rb"
  sh "rsync #{rsync_options} bin/ri #{rubinius_dir}/lib/bin/ri.rb"
  sh "rsync #{rsync_options} lib/ #{rubinius_dir}/lib"
  sh "rsync #{rsync_options} test/ #{rubinius_dir}/test/rdoc"
end

desc "Diffs Rubinius HEAD with the currently checked-out copy of RDoc."
task :diff_rubinius do
  sh "diff #{diff_options} bin/rdoc #{rubinius_dir}/lib/bin/rdoc.rb; true"
  sh "diff #{diff_options} bin/ri #{rubinius_dir}/lib/bin/ri.rb; true"
  sh "diff #{diff_options} lib/rdoc.rb #{rubinius_dir}/lib/rdoc.rb; true"
  sh "diff #{diff_options} lib/rdoc #{rubinius_dir}/lib/rdoc; true"
  sh "diff #{diff_options} test #{rubinius_dir}/test/rdoc; true"
end

