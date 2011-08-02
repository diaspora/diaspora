# When installed as a plugin this is loaded automatically.
#
# When installed as a gem, you need to add
#  require 'new_relic/recipes'
# to your deploy.rb
#
# Defined deploy:notify_rpm which will send information about the deploy to New Relic.
# The task will run on app servers except where no_release is true.
# If it fails, it will not affect the task execution or do a rollback.
#
make_notify_task = Proc.new do

  namespace :newrelic do

    # on all deployments, notify New Relic
    desc "Record a deployment in New Relic (newrelic.com)"
    task :notice_deployment, :roles => :app, :except => {:no_release => true } do
      rails_env = fetch(:newrelic_rails_env, fetch(:rails_env, "production"))
      require File.join(File.dirname(__FILE__), 'command.rb')
      begin
        # allow overrides to be defined for revision, description, changelog and appname
        rev = fetch(:newrelic_revision) if exists?(:newrelic_revision)
        description = fetch(:newrelic_desc) if exists?(:newrelic_desc)
        changelog = fetch(:newrelic_changelog) if exists?(:newrelic_changelog)
        appname = fetch(:newrelic_appname) if exists?(:newrelic_appname)
        if !changelog
          logger.debug "Getting log of changes for New Relic Deployment details"
          from_revision = source.next_revision(current_revision)
          if scm == :git
            log_command = "git log --no-color --pretty=format:'  * %an: %s' --abbrev-commit --no-merges #{previous_revision}..#{real_revision}"
          else
            log_command = "#{source.log(from_revision)}"
          end
          changelog = `#{log_command}`
        end
        new_revision = rev || source.query_revision(source.head()) do |cmd|
          logger.debug "executing locally: '#{cmd}'"
          `#{cmd}`
        end
        deploy_options = { :environment => rails_env,
          :revision => new_revision,
          :changelog => changelog,
          :description => description,
          :appname => appname }
        logger.debug "Uploading deployment to New Relic"
        deployment = NewRelic::Command::Deployments.new deploy_options
        deployment.run
        logger.info "Uploaded deployment information to New Relic"
      rescue NewRelic::Command::CommandFailure => e
        logger.info e.message
      rescue Capistrano::CommandError
        logger.info "Unable to notify New Relic of the deployment... skipping"
      rescue Exception => e
        logger.info "Error creating New Relic deployment (#{e})\n#{e.backtrace.join("\n")}"
      end
      # WIP: For rollbacks, let's update the deployment we created with an indication of the failure:
      # on_rollback do
      #   run(...)
      # end
    end
  end
end
require 'capistrano/version'
if defined?(Capistrano::Version::MAJOR) && Capistrano::Version::MAJOR < 2
  STDERR.puts "Unable to load #{__FILE__}\nNew Relic Capistrano hooks require at least version 2.0.0"
else
  instance = Capistrano::Configuration.instance
  if instance
    instance.load &make_notify_task
  else
    make_notify_task.call
  end
end
