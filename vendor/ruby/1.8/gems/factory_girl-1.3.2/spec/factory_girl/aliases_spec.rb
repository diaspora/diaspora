require 'spec_helper'

describe Factory, "aliases" do

  it "should include an attribute as an alias for itself by default" do
    Factory.aliases_for(:test).should include(:test)
  end

  it "should include the root of a foreign key as an alias by default" do
    Factory.aliases_for(:test_id).should include(:test)
  end

  it "should include an attribute's foreign key as an alias by default" do
    Factory.aliases_for(:test).should include(:test_id)
  end

  it "should NOT include an attribute as an alias when it starts with underscore" do
    Factory.aliases_for(:_id).should_not include(:id)
  end

  describe "after adding an alias" do

    before do
      Factory.alias(/(.*)_suffix/, '\1')
    end

    it "should return the alias in the aliases list" do
      Factory.aliases_for(:test_suffix).should include(:test)
    end

  end

end
