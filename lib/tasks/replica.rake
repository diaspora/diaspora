require "English"
require "rspec/core/rake_task"
require "diaspora_api"
require "logger"
DIASPORA_ROOT = "#{File.dirname(__FILE__)}/../..".freeze
require "#{DIASPORA_ROOT}/spec_federation/config"
require "#{DIASPORA_ROOT}/replica/api"

include Diaspora::Replica::API

self.logdir = "#{DIASPORA_ROOT}/log"

namespace :replica do
  def within_diaspora_replica(*_args)
    Bundler.with_clean_env do
      super
    end
  end

  def eye(*_args)
    Bundler.with_clean_env do
      super
    end
  end

  def testenv_off?
    (1..pod_count).each do |pod_nr|
      return true if machine_off?("pod#{pod_nr}")
    end
    false
  end

  def launch_pod(pod_nr)
    if diaspora_up?(pod_uri(pod_nr))
      logger.info "Pod number #{pod_nr} is already up!"
    else
      eye("start", "test", "SERVER_URL='#{pod_host(pod_nr)}'")
    end
    eye("info", "test", "SERVER_URL='#{pod_host(pod_nr)}'", true)
  end

  def stop_pod(pod_nr)
    if diaspora_up?(pod_uri(pod_nr))
      eye("stop", "test", "SERVER_URL='#{pod_host(pod_nr)}'")
    else
      logger.info "Pod number #{pod_nr} isn't up!"
    end
  end

  def deploy_app_revision(pod_nr, revision)
    report_info "Deploying revision #{revision} on pod#{pod_nr}"
    Bundler.with_clean_env do
      deploy_app("test", "BRANCH=#{revision} SERVER_URL='#{pod_host(pod_nr)}'")
    end
  end

  def install_vagrant_plugin(name)
    within_diaspora_replica do
      unless `vagrant plugin list`.include?(name)
        pipesh "vagrant plugin install #{name}"
      end
    end
  end

  task :install_vagrant_requirements do
    install_vagrant_plugin("vagrant-hosts")
    install_vagrant_plugin("vagrant-group")
    install_vagrant_plugin("vagrant-puppet-install")
    install_vagrant_plugin("vagrant-lxc")
  end

  task :check_repository_clone do
    within_diaspora_replica do
      pipesh "ln -fs -T #{DIASPORA_ROOT}/ src"
      `cd src && git status`
      # if $? == 0
      #  pipesh "cd src && git fetch --all"
      # end
    end
  end

  task bring_up_testfarm: %i(install_vagrant_requirements check_repository_clone) do
    ENV["pod_count"] = pod_count.to_s
    report_info `vagrant --version`
    report_info `ruby --version`
    if testenv_off?
      report_info "Bringing up test environment"
      within_diaspora_replica { pipesh "env pod_count=#{pod_count} vagrant group up testfarm" }
      exit 1 unless $CHILD_STATUS == 0
    end
  end

  task deploy_apps: :bring_up_testfarm do
    (1..pod_count).each do |i|
      deploy_app_revision(i, environment_configuration["pod#{i}"]["revisions"].first)
    end
  end

  task launch_pods: :bring_up_testfarm do
    if testenv_off?
      logger.info "Required machines are halted! Aborting"
    else
      (1..pod_count).each do |i|
        launch_pod(i)
      end
      (1..pod_count).each do |i|
        next if wait_pod_up(pod_uri(i))
        report_error "Error encountered during pod #{i} launch"
        break
      end
    end
  end

  task :stop_pods do
    (1..pod_count).each do |i|
      stop_pod(i)
    end
  end

  def deploy_and_launch_pod(pod_nr, revision)
    unless deploy_app_revision(pod_nr, revision) == 0
      report_error "Failed to deploy pod#{pod_nr} with revision #{revision}"
      return false
    end

    unless launch_pod(pod_nr) == 0
      report_error "Failed to launch pod #{pod_nr}"
      return false
    end

    unless wait_pod_up(pod_uri(pod_nr))
      report_error "Pod #{pod_nr} wasn't up after the launch attempt. Tests won't run."
      return false
    end

    true
  end

  def deploy_and_launch_testfarm(pod_nr=1, &f)
    environment_configuration["pod#{pod_nr}"]["revisions"].each do |revision|
      unless deploy_and_launch_pod(pod_nr, revision)
        @failure = true
        next
      end

      if pod_nr < pod_count
        deploy_and_launch_testfarm(pod_nr + 1, &f)
      else
        yield
      end
      stop_pod(pod_nr)
    end
  end

  task :reset_databases do
    (1..pod_count).each do |i|
      within_capistrano do
        pipesh "bundle exec env SERVER_URL='#{pod_host(i)}' cap test"\
          " rails:rake:db:drop rails:rake:db:setup diaspora:fixtures:generate_and_load"
      end
    end
  end

  task :execute_tests, [:arg] => %i(bring_up_testfarm stop_pods) do |_task, args|
    deploy_and_launch_testfarm do
      report_info "Launching the test suite"
      if pipesh_log_and_stdout("bin/rspec #{args[:arg]} --default-path spec_federation --format documentation") == 0
        report_info "Test suite finished correctly"
      else
        report_error "Test suite failed"
        @failure = true
      end
    end
    exit 1 if @failure
  end

  task :clean do
    within_diaspora_replica { system "env pod_count=#{pod_count} vagrant group destroy testfarm" }
  end
end
