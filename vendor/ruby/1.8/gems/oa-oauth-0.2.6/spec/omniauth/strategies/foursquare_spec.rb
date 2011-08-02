require File.expand_path('../../../spec_helper', __FILE__)

describe OmniAuth::Strategies::Foursquare do
  it_should_behave_like "an oauth2 strategy"
  subject{ OmniAuth::Strategies::Foursquare.new(lambda{|env|[200,{},[""]]} , 'abc', 'def')}

  it 'should use the mobile authorize url when :mobile is true' do
    subject.authorize_url(:mobile => true).should be_include("/mobile/")
  end

  it 'should use the authorize endpoint if :sign_in is false' do
    subject.authorize_url(:sign_in => false).should be_include("/authorize")
  end

  it 'should default to the authenticate endpoint' do
    subject.client.authorize_url.should be_include('/authenticate')
  end
end
