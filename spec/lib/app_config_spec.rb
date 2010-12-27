# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require 'spec_helper'

describe AppConfig do
  describe ".generate_pod_uri" do
    before do
      @environment_vars = AppConfig.config_vars
      AppConfig.config_vars = {}
    end
    after do
      AppConfig.config_vars = @environment_vars
    end
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