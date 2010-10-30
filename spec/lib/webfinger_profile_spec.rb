require 'spec_helper'

describe WebfingerProfile do
  let(:webfinger_profile){File.open(File.join(Rails.root, "spec/fixtures/finger_xrd")).read.strip}
  let(:not_diaspora_webfinger){File.open(File.join(Rails.root, "spec/fixtures/nonseed_finger_xrd")).read.strip}

  let(:account){"tom@tom.joindiaspora.com"}
  let(:profile){ WebfingerProfile.new(account, webfinger_profile) }
  
  context "parsing a diaspora profile" do
    
    describe '#valid_diaspora_profile?' do
      it 'should check all of the required fields' do
        manual_nil_check(profile).should == profile.valid_diaspora_profile?
      end
    end

    describe '#set_fields' do
      it 'should check to make sure it has a the right webfinger profile' do
        proc{ WebfingerProfile.new("nottom@tom.joindiaspora.com", webfinger_profile)}.should raise_error 
      end

      it 'should handle a non-diaspora profile without blowing up' do
        proc{ WebfingerProfile.new("evan@status.net", not_diaspora_webfinger)}.should_not raise_error 
      end
    end
  end

    def manual_nil_check(profile)
      profile.instance_variables.each do |var|
        var = var.to_s.gsub('@', '')
        return false if profile.send(var).nil? == true
      end
      true
    end
end
