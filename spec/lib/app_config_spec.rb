# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'

describe AppConfig do
  before do
    @environment_vars = AppConfig.config_vars
    AppConfig.config_vars = {}
  end
  after do
    AppConfig.config_vars = @environment_vars
  end
  describe ".base_file_path" do
    it "allows you to set the base file path" do
      AppConfig.base_file_path = "foo"
      AppConfig.base_file_path.should == "foo"
    end
    it "defaults to config/app_base.yml" do
      AppConfig.base_file_path = nil
      AppConfig.base_file_path.should == "#{Rails.root}/config/app_base.yml"
    end
  end
  describe ".load_config_for_environment" do
    before do
      @original_stderr = $stderr
      $stderr = StringIO.new
    end
    after do
      $stderr = @original_stderr
    end
    it "prints error if base file is missing" do
      AppConfig.base_file_path = "/no/such/file"
      AppConfig.file_path = File.join(Rails.root, "config", "app_base.yml")

      AppConfig.load_config_for_environment(:test)
      $stderr.rewind
      $stderr.string.chomp.should_not be_blank
    end
    it "prints error and exits if there's no config at all" do
      AppConfig.base_file_path = "/no/such/file"
      AppConfig.file_path = "/no/such/file"
      
      lambda {
        AppConfig.load_config_for_environment(:test)
      }.should raise_error SystemExit
      
      $stderr.rewind
      $stderr.string.chomp.should_not be_blank
    end
  end
  describe ".generate_pod_uri" do
    describe "when pod_url is prefixed with protocol" do
      it "generates a URI with a host for http" do
        AppConfig[:pod_url] = "http://oscar.joindiaspora.com"
        AppConfig.generate_pod_uri
        AppConfig[:pod_uri].host.should == "oscar.joindiaspora.com"
      end
      it "generates a URI with a host for https" do
        AppConfig[:pod_url] = "https://oscar.joindiaspora.com"
        AppConfig.generate_pod_uri
        AppConfig[:pod_uri].host.should == "oscar.joindiaspora.com"
      end
    end
    describe "when pod_url is not prefixed with protocol" do
      it "generates a URI with a host" do
        AppConfig[:pod_url] = "oscar.joindiaspora.com"
        AppConfig.generate_pod_uri
        AppConfig[:pod_uri].host.should == "oscar.joindiaspora.com"
      end
      it "adds http:// to the front of the pod_url" do
        AppConfig[:pod_url] = "oscar.joindiaspora.com"
        AppConfig.generate_pod_uri
        AppConfig[:pod_url].should == "http://oscar.joindiaspora.com"
      end
    end
  end
end
