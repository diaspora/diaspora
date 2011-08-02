require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe "ActiveRecord::ConnectionAdapter::AbstractAdapter" do
  context "#get_insert_value_sets - computing insert value sets" do
    let(:adapter){ ActiveRecord::ConnectionAdapters::AbstractAdapter }
    let(:base_sql){ "INSERT INTO atable (a,b,c)" }
    let(:values){ [ "(1,2,3)", "(2,3,4)", "(3,4,5)" ] }
    
    context "when the max allowed bytes is 33 and the base SQL is 26 bytes" do
      it "should return 3 value sets when given 3 value sets of 7 bytes a piece" do
        value_sets = adapter.get_insert_value_sets values, base_sql.size, max_allowed_bytes = 33
        assert_equal 3, value_sets.size
      end
    end
  
    context "when the max allowed bytes is 40 and the base SQL is 26 bytes" do
      it "should return 3 value sets when given 3 value sets of 7 bytes a piece" do
        value_sets = adapter.get_insert_value_sets values, base_sql.size, max_allowed_bytes = 40
        assert_equal 3, value_sets.size
      end
    end
      
    context "when the max allowed bytes is 41 and the base SQL is 26 bytes" do
      it "should return 2 value sets when given 2 value sets of 7 bytes a piece" do
        value_sets = adapter.get_insert_value_sets values, base_sql.size, max_allowed_bytes = 41
        assert_equal 2, value_sets.size
      end
    end
      
    context "when the max allowed bytes is 48 and the base SQL is 26 bytes" do
      it "should return 2 value sets when given 2 value sets of 7 bytes a piece" do
        value_sets = adapter.get_insert_value_sets values, base_sql.size, max_allowed_bytes = 48
        assert_equal 2, value_sets.size
      end
    end
      
    context "when the max allowed bytes is 49 and the base SQL is 26 bytes" do
      it "should return 1 value sets when given 1 value sets of 7 bytes a piece" do
        value_sets = adapter.get_insert_value_sets values, base_sql.size, max_allowed_bytes = 49
        assert_equal 1, value_sets.size
      end
    end
      
    context "when the max allowed bytes is 999999 and the base SQL is 26 bytes" do
      it "should return 1 value sets when given 1 value sets of 7 bytes a piece" do
        value_sets = adapter.get_insert_value_sets values, base_sql.size, max_allowed_bytes = 999999
        assert_equal 1, value_sets.size
      end
    end
  end
  
end
