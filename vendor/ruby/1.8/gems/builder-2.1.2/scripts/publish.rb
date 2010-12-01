# Optional publish task for Rake

require 'rake/contrib/sshpublisher'
require 'rake/contrib/rubyforgepublisher'

publisher = Rake::CompositePublisher.new
publisher.add Rake::RubyForgePublisher.new('builder', 'jimweirich')
publisher.add Rake::SshFilePublisher.new(
  'umlcoop',
  'htdocs/software/builder',
  '.',
  'builder.blurb')

desc "Publish the Documentation to RubyForge."
task :publish => [:rdoc] do
  publisher.upload
end
