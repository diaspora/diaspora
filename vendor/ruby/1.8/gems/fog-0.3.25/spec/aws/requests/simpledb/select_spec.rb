require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'SimpleDB.select' do
  describe 'success' do

    before(:each) do
      @domain_name = "fog_domain_#{Time.now.to_i}"
      AWS[:sdb].create_domain(@domain_name)
    end

    after(:each) do
      AWS[:sdb].delete_domain(@domain_name)
    end

    it 'should return multi-value attributes when present' do
      pending if Fog.mocking?
      @item = "someitem_fog_domain_#{Time.now.to_i}"
      AWS[:sdb].put_attributes(@domain_name, @item, { "attr" => "foo" })
      AWS[:sdb].put_attributes(@domain_name, @item, { "attr" => "foo2" })
      eventually do
        actual = AWS[:sdb].select("select * from #{@domain_name}")
        actual.body['Items'][@item]["attr"].should == ['foo','foo2']
      end
    end

  end
end
