require 'spec_helper'

describe Hashie::Trash do
  class TrashTest < Hashie::Trash
    property :first_name, :from => :firstName
  end

  let(:trash) { TrashTest.new }

  describe 'translating properties' do
    it 'adds the property to the list' do
      TrashTest.properties.should include(:first_name)
    end

    it 'creates a method for reading the property' do
      trash.should respond_to(:first_name)
    end

    it 'creates a method for writing the property' do
      trash.should respond_to(:first_name=)
    end

    it 'creates a method for writing the translated property' do
      trash.should respond_to(:firstName=)
    end

    it 'does not create a method for reading the translated property' do
      trash.should_not respond_to(:firstName)
    end
  end

  describe 'writing to properties' do

    it 'does not write to a non-existent property using []=' do
      lambda{trash['abc'] = 123}.should raise_error(NoMethodError)
    end

    it 'writes to an existing property using []=' do
      lambda{trash['first_name'] = 'Bob'}.should_not raise_error
    end

    it 'writes to a translated property using []=' do
      lambda{trash['firstName'] = 'Bob'}.should_not raise_error
    end

    it 'reads/writes to an existing property using a method call' do
      trash.first_name = 'Franklin'
      trash.first_name.should == 'Franklin'
    end

    it 'writes to an translated property using a method call' do
      trash.firstName = 'Franklin'
      trash.first_name.should == 'Franklin'
    end
  end

  describe ' initializing with a Hash' do
    it 'does not initialize non-existent properties' do
      lambda{TrashTest.new(:bork => 'abc')}.should raise_error(NoMethodError)
    end

    it 'sets the desired properties' do
      TrashTest.new(:first_name => 'Michael').first_name.should == 'Michael'
    end

    it 'sets the translated properties' do
      TrashTest.new(:firstName => 'Michael').first_name.should == 'Michael'
    end
  end
end
