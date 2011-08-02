require 'spec_helper'
require File.dirname(__FILE__) + '/ar_classes'

describe "mock_model(RealModel)" do

  context "given a String" do
    context "that does not represent an existing constant" do
      it "class says it's name" do
        model = mock_model("Foo")
        model.class.name.should eq("Foo")
      end
    end

    context "that represents an existing constant" do
      context "that extends ActiveModel::Naming" do
        it "treats the constant as the class" do
          model = mock_model("MockableModel")
          model.class.name.should eq("MockableModel")
        end
      end

      context "that does not extend ActiveModel::Naming" do
        it "raises with a helpful message" do
          expect do
            mock_model("String")
          end.to raise_error(ArgumentError)
        end
      end
    end
  end

  context "given a class that does not extend ActiveModel::Naming" do
    it "raises with a helpful message" do
      expect do
        mock_model(String)
      end.to raise_error(ArgumentError)
    end
  end

  describe "with #id stubbed" do
    before(:each) do
      @model = mock_model(MockableModel, :id => 1)
    end

    it "is named using the stubbed id value" do
      @model.instance_variable_get(:@name).should == "MockableModel_1"
    end
  end

  describe "destroy" do
    it "sets persisted to false" do
      model = mock_model(MockableModel)
      model.destroy
      model.should_not be_persisted
    end
  end

  describe "errors" do
    context "default" do
      it "is empty" do
        model = mock_model(MockableModel)
        model.errors.should be_empty
      end
    end

    context "with :save => false" do
      it "is not empty" do
        model = mock_model(MockableModel, :save => false)
        model.errors.should_not be_empty
      end
    end

    context "with :update_attributes => false" do
      it "is not empty" do
        model = mock_model(MockableModel, :save => false)
        model.errors.should_not be_empty
      end
    end
  end

  describe "with params" do
    it "does not mutate its parameters" do
      params = {:a => 'b'}
      model = mock_model(MockableModel, params)
      params.should == {:a => 'b'}
    end
  end

  describe "as association" do
    before(:each) do
      @real = AssociatedModel.create!
      @mock_model = mock_model(MockableModel)
      @real.mockable_model = @mock_model
    end

    it "passes: associated_model == mock" do
      @mock_model.should == @real.mockable_model
    end

    it "passes: mock == associated_model" do
      @real.mockable_model.should == @mock_model
    end
  end

  describe "#is_a?" do
    before(:each) do
      @model = mock_model(SubMockableModel)
    end
    it "says it is_a?(RealModel)" do
      @model.is_a?(SubMockableModel).should be(true)
    end
    it "says it is_a?(OtherModel) if RealModel is an ancestors" do
      @model.is_a?(MockableModel).should be(true)
    end
  end

  describe "#kind_of?" do
    before(:each) do
      @model = mock_model(SubMockableModel)
    end
    it "says it is kind_of? if RealModel is" do
      @model.kind_of?(SubMockableModel).should be(true)
    end
    it "says it is kind_of? if RealModel's ancestor is" do
      @model.kind_of?(MockableModel).should be(true)
    end
  end

  describe "#instance_of?" do
    before(:each) do
      @model = mock_model(SubMockableModel)
    end
    it "says it is instance_of? if RealModel is" do
      @model.instance_of?(SubMockableModel).should be(true)
    end
    it "does not say it instance_of? if RealModel isn't, even if it's ancestor is" do
      @model.instance_of?(MockableModel).should be(false)
    end
  end

  describe "#respond_to?" do
    context "with an ActiveRecord model" do
      before(:each) do
        MockableModel.stub(:column_names).and_return(["column_a", "column_b"])
        @model = mock_model(MockableModel)
      end

      it "accepts two arguments" do
        expect do
          @model.respond_to?("title_before_type_cast", false)
        end.to_not raise_exception
      end

      context "without as_null_object" do
        it "says it will respond_to?(key) if RealModel has the attribute 'key'" do
          @model.respond_to?("column_a").should be(true)
        end
        it "says it will not respond_to?(key) if RealModel does not have the attribute 'key'" do
          @model.respond_to?("column_c").should be(false)
        end
        it "says it will not respond_to?(xxx_before_type_cast)" do
          @model.respond_to?("title_before_type_cast").should be(false)
        end
      end
      context "with as_null_object" do
        it "says it will respond_to?(key) if RealModel has the attribute 'key'" do
          @model.as_null_object.respond_to?("column_a").should be(true)
        end
        it "says it will respond_to?(key) even if RealModel does not have the attribute 'key'" do
          @model.as_null_object.respond_to?("column_c").should be(true)
        end
        it "says it will not respond_to?(xxx_before_type_cast)" do
          @model.as_null_object.respond_to?("title_before_type_cast").should be(false)
        end
      end
    end

    context "with a non-ActiveRecord model" do
      it "responds as normal" do
        model = NonActiveRecordModel.new
        model.should respond_to(:to_param)
      end
      context "with as_null_object" do
        it "says it will not respond_to?(xxx_before_type_cast)" do
          model = NonActiveRecordModel.new.as_null_object
          model.respond_to?("title_before_type_cast").should be(false)
        end
      end
    end
  end

  describe "#destroyed?" do
    context "default" do
      it "returns false" do
        @model = mock_model(SubMockableModel)
        @model.destroyed?.should be(false)
      end
    end
  end

  describe "#marked_for_destruction?" do
    context "default" do
      it "returns false" do
        @model = mock_model(SubMockableModel)
        @model.marked_for_destruction?.should be(false)
      end
    end
  end

  describe "#persisted?" do
    context "with default identifier" do
      it "returns true" do
        mock_model(MockableModel).should be_persisted
      end
    end

    context "with explicit identifier via :id" do
      it "returns true" do
        mock_model(MockableModel, :id => 37).should be_persisted
      end
    end

    context "with id => nil" do
      it "returns false" do
        mock_model(MockableModel, :id => nil).should_not be_persisted
      end
    end
  end

  describe "#valid?" do
    context "default" do
      it "returns true" do
        mock_model(MockableModel).should be_valid
      end
    end
    context "stubbed with false" do
      it "returns false" do
        mock_model(MockableModel, :valid? => false).should_not be_valid
      end
    end
  end

  describe "#as_new_record" do
    it "says it is a new record" do
      m = mock_model(MockableModel)
      m.as_new_record.should be_new_record
    end

    it "says it is not persisted" do
      m = mock_model(MockableModel)
      m.as_new_record.should_not be_persisted
    end

    it "has a nil id" do
      mock_model(MockableModel).as_new_record.id.should be(nil)
    end

    it "returns nil for #to_param" do
      mock_model(MockableModel).as_new_record.to_param.should be(nil)
    end
  end

  describe "#blank?" do
    it "is false" do
      mock_model(MockableModel).should_not be_blank
    end
  end

  describe "ActiveModel Lint tests" do
    require 'test/unit/assertions'
    require 'active_model/lint'
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end

    def model
      mock_model(MockableModel, :id => nil)
    end
  end
end
