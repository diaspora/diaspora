require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'SimpleDB.create_domain' do
  before(:each) do
    @domain_name = "fog_domain_#{Time.now.to_i}"
  end

  after(:each) do
    AWS[:sdb].delete_domain(@domain_name)
  end

  describe 'success' do

    it 'should return proper attributes' do
      actual = AWS[:sdb].create_domain(@domain_name)
      actual.body['RequestId'].should be_a(String)
      actual.body['BoxUsage'].should be_a(Float)
    end

  end
  describe 'failure' do

    it 'should not raise an error if the domain already exists' do
      AWS[:sdb].create_domain(@domain_name)
      AWS[:sdb].create_domain(@domain_name)
    end

  end
end
