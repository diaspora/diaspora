require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'SimpleDB.delete_attributes' do
  describe 'success' do

    before(:each) do
      @domain_name = "fog_domain_#{Time.now.to_i}"
      AWS[:sdb].create_domain(@domain_name)
      AWS[:sdb].put_attributes(@domain_name, 'foo', { :bar => :baz })
    end

    after(:each) do
      AWS[:sdb].delete_domain(@domain_name)
    end

    it 'should return proper attributes from delete_attributes' do
      actual = AWS[:sdb].delete_attributes(@domain_name, 'foo')
      actual.body['RequestId'].should be_a(String)
      actual.body['BoxUsage'].should be_a(Float)
    end

  end
  describe 'failure' do

    it 'shouild raise a BadRequest error if the domain does not exist' do
      lambda {
        AWS[:sdb].delete_attributes('notadomain', 'notanattribute')
      }.should raise_error(Excon::Errors::BadRequest)
    end

    it 'should not raise an error if the attribute does not exist' do
      @domain_name = "fog_domain_#{Time.now.to_i}"
      AWS[:sdb].create_domain(@domain_name)
      AWS[:sdb].delete_attributes(@domain_name, 'notanattribute')
      AWS[:sdb].delete_domain(@domain_name)
    end

  end
end
