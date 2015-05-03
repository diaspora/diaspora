require 'spec_helper'

describe WebfingerProfile do
  let(:webfinger_profile){File.open(Rails.root.join("spec", "fixtures", "finger_xrd")).read.strip}
  let(:not_diaspora_webfinger){File.open(Rails.root.join("spec", "fixtures", "nonseed_finger_xrd")).read.strip}

  let(:account){"tom@tom.joindiaspora.com"}
  let(:profile){ WebfingerProfile.new(account, webfinger_profile) }
  
  context "parsing a diaspora profile" do
    
    describe '#valid_diaspora_profile?' do
      it 'should check all of the required fields' do
        expect(manual_nil_check(profile)).to eq(profile.valid_diaspora_profile?)
      end
    end

    describe '#set_fields' do
      it 'should check to make sure it has a the right webfinger profile' do
        expect{ WebfingerProfile.new("nottom@tom.joindiaspora.com", webfinger_profile)}.to raise_error 
      end

      it 'should handle a non-diaspora profile without blowing up' do
        expect{ WebfingerProfile.new("evan@status.net", not_diaspora_webfinger)}.not_to raise_error 
      end
      
      [:links, :hcard, :guid, :seed_location, :public_key].each do |field|
        it 'should sets the #{field} field' do
          expect(profile.send(field)).to be_present
        end
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
