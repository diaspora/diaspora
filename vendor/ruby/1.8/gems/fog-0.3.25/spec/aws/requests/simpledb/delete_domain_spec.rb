require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'SimpleDB.delete_domain' do
  describe 'success' do

    before(:each) do
      @domain_name = "fog_domain_#{Time.now.to_i}"
    end

    before(:each) do
      AWS[:sdb].create_domain(@domain_name)
    end

    it 'should return proper attributes' do
      actual = AWS[:sdb].delete_domain(@domain_name)
      actual.body['RequestId'].should be_a(String)
      actual.body['BoxUsage'].should be_a(Float)
    end

  end
  describe 'failure' do

    it 'should not raise an error if the domain does not exist' do
      AWS[:sdb].delete_domain('notadomain')
    end

  end
end
