#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AppConfig do

  after do
    AppConfig.reload!
    AppConfig.setup!
  end

  describe ".load!" do
    context "error conditions" do
      before do
        @original_stderr = $stderr
        $stderr = StringIO.new
      end
      after do
        $stderr = @original_stderr
      end

      context "with old-style application.yml" do
        before do
          @original_source = AppConfig.source
          AppConfig.source(File.join(Rails.root, "spec", "fixtures", "config", "old_style_app.yml"))
        end
        after do
          AppConfig.source(@original_source)
        end
        it "prints an error message and exits" do
          expect {
            AppConfig.load!
          }.should raise_error SystemExit

          $stderr.rewind
          $stderr.string.chomp.should_not be_blank
        end
      end

      context "when source config file (i.e. config/application.yml) does not exist" do
        before do
          application_yml = AppConfig.source_file_name
          @app_yml = File.join(Rails.root, "config", "app.yml")
          @app_config_yml = File.join(Rails.root, "config", "app_config.yml")
          File.should_receive(:exists?).with(application_yml).at_least(:once).and_return(false)
        end
        after do
          File.instance_eval { alias :exists? :obfuscated_by_rspec_mocks__exists? } # unmock exists? so that the AppConfig.reload! in the top-level after block can run
          AppConfig.source(AppConfig.source_file_name)
        end
        context "and there are no old-style config files around" do
          it "prints an error message with instructions for setting up application.yml and exits" do
            File.should_receive(:exists?).with(@app_yml).at_least(:once).and_return(false)
            File.should_receive(:exists?).with(@app_config_yml).at_least(:once).and_return(false)

            expect {
              AppConfig.load!
            }.should raise_error SystemExit

            $stderr.rewind
            $stderr.string.should include("haven't set up")
          end
        end
        context "and there is an old-style app.yml" do
          it "prints an error message with instructions for converting an old-style file and exits" do
            File.should_receive(:exists?).with(@app_yml).at_least(:once).and_return(true)

            expect {
              AppConfig.load!
            }.should raise_error SystemExit

            $stderr.rewind
            $stderr.string.should include("file format has changed")
          end
        end
        context "and there is an old-style app_config.yml" do
          it "prints an error message with instructions for converting an old-style file and exits" do
            File.should_receive(:exists?).with(@app_yml).at_least(:once).and_return(false)
            File.should_receive(:exists?).with(@app_config_yml).at_least(:once).and_return(true)

            expect {
              AppConfig.load!
            }.should raise_error SystemExit

            $stderr.rewind
            $stderr.string.should include("file format has changed")
          end
        end
      end
    end
  end
  
  describe '.setup!' do
    it "calls normalize_pod_url" do
      AppConfig.should_receive(:normalize_pod_url).twice
      AppConfig.setup!
    end
    it "calls normalize_admins" do
      AppConfig.should_receive(:normalize_admins).twice
      AppConfig.setup!
    end
  end

  describe ".normalize_admins" do
    it "downcases the user names that are set as admins" do
      AppConfig[:admins] = ["UPPERCASE", "MiXeDCaSe", "lowercase"]
      AppConfig.normalize_admins
      AppConfig[:admins].should == ["uppercase", "mixedcase", "lowercase"]
    end
    it "sets admins to an empty array if no admins were specified" do
      AppConfig[:admins] = nil
      AppConfig.normalize_admins
      AppConfig[:admins].should == []
    end
  end

  describe ".normalize_pod_url" do
    it "adds a trailing slash if there isn't one" do
      AppConfig[:pod_url] = "http://example.org"
      AppConfig.normalize_pod_url
      AppConfig[:pod_url].should == "http://example.org/"
    end
    it "does not add an extra trailing slash" do
      AppConfig[:pod_url] = "http://example.org/"
      AppConfig.normalize_pod_url
      AppConfig[:pod_url].should == "http://example.org/"
    end
    it "adds http:// on the front if it's missing" do
      AppConfig[:pod_url] = "example.org/"
      AppConfig.normalize_pod_url
      AppConfig[:pod_url].should == "http://example.org/"
    end
    it "does not add a prefix if there already is http:// on the front" do
      AppConfig[:pod_url] = "http://example.org/"
      AppConfig.normalize_pod_url
      AppConfig[:pod_url].should == "http://example.org/"
    end
    it "does not add a prefix if there already is https:// on the front" do
      AppConfig[:pod_url] = "https://example.org/"
      AppConfig.normalize_pod_url
      AppConfig[:pod_url].should == "https://example.org/"
    end

  end

  describe '.bare_pod_uri' do
    it 'is AppConfig[:pod_uri].authority stripping www.' do
      AppConfig[:pod_url] = "https://www.example.org/"
      AppConfig.bare_pod_uri.should == 'example.org'
    end
  end

  describe ".pod_uri" do
    it "properly parses the pod_url" do
      AppConfig.pod_uri = nil
      AppConfig[:pod_url] = "http://example.org"
      pod_uri = AppConfig[:pod_uri]
      pod_uri.scheme.should == "http"
      pod_uri.host.should == "example.org"
    end
  end

  describe '.normalize_services' do
    before do
      @services = SERVICES
      Object.send(:remove_const, :SERVICES)
    end

    after do
      SERVICES = @services
    end

    it 'sets configured_services to an empty array if SERVICES is not defined' do
      AppConfig.normalize_pod_services
      AppConfig.configured_services.should == []
    end
  end

  describe ".[]=" do
    describe "when setting pod_url" do
      context "with a symbol" do
        it "clears the cached pod_uri" do
          AppConfig[:pod_uri].host.should_not == "joindiaspora.com"
          AppConfig[:pod_url] = "http://joindiaspora.com"
          AppConfig[:pod_uri].host.should == "joindiaspora.com"
        end
        it "calls normalize_pod_url" do
          AppConfig.should_receive(:normalize_pod_url).twice
          AppConfig[:pod_url] = "http://joindiaspora.com"
        end
      end
      context "with a string" do
        it "clears the cached pod_uri" do
          AppConfig[:pod_uri].host.should_not == "joindiaspora.com"
          AppConfig['pod_url'] = "http://joindiaspora.com"
          AppConfig[:pod_uri].host.should == "joindiaspora.com"
        end
        it "calls normalize_pod_url" do
          AppConfig.should_receive(:normalize_pod_url).twice
          AppConfig['pod_url'] = "http://joindiaspora.com"
        end
      end
    end
  end
end
