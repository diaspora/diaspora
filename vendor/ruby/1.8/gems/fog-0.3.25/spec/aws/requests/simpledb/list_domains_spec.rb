require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'SimpleDB.list_domains' do
  describe 'success' do

    before(:each) do
      @domain_name = "fog_domain_#{Time.now.to_i}"
    end

    after(:each) do
      AWS[:sdb].delete_domain(@domain_name)
    end

    it 'should return proper attributes' do
      results = AWS[:sdb].list_domains
      results.body['BoxUsage'].should be_a(Float)
      results.body['Domains'].should be_an(Array)
      results.body['RequestId'].should be_a(String)
    end

    it 'should include created domains' do
      AWS[:sdb].create_domain(@domain_name)
      eventually do
        actual = AWS[:sdb].list_domains
        actual.body['Domains'].should include(@domain_name)
      end
    end

  end
end
