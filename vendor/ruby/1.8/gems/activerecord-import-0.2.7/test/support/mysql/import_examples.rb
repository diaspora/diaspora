def should_support_mysql_import_functionality

  describe "building insert value sets" do
    it "should properly build insert value set based on max packet allowed" do
      values = [
        "('1','2','3')",
        "('4','5','6')",
        "('7','8','9')" ]
      
      adapter = ActiveRecord::Base.connection.class
      values_size_in_bytes = adapter.sum_sizes( *values )
      base_sql_size_in_bytes = 15
      max_bytes = 30
    
      value_sets = adapter.get_insert_value_sets( values, base_sql_size_in_bytes, max_bytes )
      assert_equal 3, value_sets.size, 'Three value sets were expected!'
     
      # Each element in the value_sets array must be an array
      value_sets.each_with_index { |e,i| 
        assert_kind_of Array, e, "Element #{i} was expected to be an Array!" }

      # Each element in the values array should have a 1:1 correlation to the elements
      # in the returned value_sets arrays
      assert_equal values[0], value_sets[0].first
      assert_equal values[1], value_sets[1].first
      assert_equal values[2], value_sets[2].first
    end
  end

  describe "#import with :on_duplicate_key_update option (mysql specific functionality)" do
    extend ActiveSupport::TestCase::MySQLAssertions
  
    asssertion_group(:should_support_on_duplicate_key_update) do
      should_not_update_fields_not_mentioned
      should_update_foreign_keys
      should_not_update_created_at_on_timestamp_columns
      should_update_updated_at_on_timestamp_columns
    end
  
    macro(:perform_import){ raise "supply your own #perform_import in a context below" }
    macro(:updated_topic){ Topic.find(@topic) }
  
    context "given columns and values with :validation checks turned off" do
      let(:columns){  %w( id title author_name author_email_address parent_id ) }
      let(:values){ [ [ 99, "Book", "John Doe", "john@doe.com", 17 ] ] }
      let(:updated_values){ [ [ 99, "Book - 2nd Edition", "Author Should Not Change", "johndoe@example.com", 57 ] ] }
  
      macro(:perform_import) do |*opts|
        Topic.import columns, updated_values, opts.extract_options!.merge(:on_duplicate_key_update => update_columns, :validate => false)
      end
    
      setup do
        Topic.import columns, values, :validate => false
        @topic = Topic.find 99
      end
    
      context "using string column names" do
        let(:update_columns){ [ "title", "author_email_address", "parent_id" ] }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
  
      context "using symbol column names" do
        let(:update_columns){ [ :title, :author_email_address, :parent_id ] }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
    
      context "using string hash map" do
        let(:update_columns){ { "title" => "title", "author_email_address" => "author_email_address", "parent_id" => "parent_id" } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
  
      context "using string hash map, but specifying column mismatches" do
        let(:update_columns){ { "title" => "author_email_address", "author_email_address" => "title", "parent_id" => "parent_id" } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned_with_hash_mappings
      end
  
      context "using symbol hash map" do
        let(:update_columns){ { :title => :title, :author_email_address => :author_email_address, :parent_id => :parent_id } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
  
      context "using symbol hash map, but specifying column mismatches" do
        let(:update_columns){ { :title => :author_email_address, :author_email_address => :title, :parent_id => :parent_id } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned_with_hash_mappings
      end
    end
  
    context "given array of model instances with :validation checks turned off" do
      macro(:perform_import) do |*opts|
        @topic.title = "Book - 2nd Edition"
        @topic.author_name = "Author Should Not Change"
        @topic.author_email_address = "johndoe@example.com"
        @topic.parent_id = 57
        Topic.import [@topic], opts.extract_options!.merge(:on_duplicate_key_update => update_columns, :validate => false)
      end
    
      setup do
        @topic = Generate(:topic, :id => 99, :author_name => "John Doe", :parent_id => 17)
      end
    
      context "using string column names" do
        let(:update_columns){ [ "title", "author_email_address", "parent_id" ] }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
  
      context "using symbol column names" do
        let(:update_columns){ [ :title, :author_email_address, :parent_id ] }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
    
      context "using string hash map" do
        let(:update_columns){ { "title" => "title", "author_email_address" => "author_email_address", "parent_id" => "parent_id" } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
  
      context "using string hash map, but specifying column mismatches" do
        let(:update_columns){ { "title" => "author_email_address", "author_email_address" => "title", "parent_id" => "parent_id" } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned_with_hash_mappings
      end
  
      context "using symbol hash map" do
        let(:update_columns){ { :title => :title, :author_email_address => :author_email_address, :parent_id => :parent_id } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned
      end
  
      context "using symbol hash map, but specifying column mismatches" do
        let(:update_columns){ { :title => :author_email_address, :author_email_address => :title, :parent_id => :parent_id } }
        should_support_on_duplicate_key_update
        should_update_fields_mentioned_with_hash_mappings
      end
    end
  
  end

  describe "#import with :synchronization option" do
    let(:topics){ Array.new } 
    let(:values){ [ [topics.first.id, "Jerry Carter"], [topics.last.id, "Chad Fowler"] ]}
    let(:columns){ %W(id author_name) }
    
    setup do
      topics << Topic.create!(:title=>"LDAP", :author_name=>"Big Bird")
      topics << Topic.create!(:title=>"Rails Recipes", :author_name=>"Elmo") 
    end
    
    it "synchronizes passed in ActiveRecord model instances with the data just imported" do
      columns2update = [ 'author_name' ]
      
      expected_count = Topic.count
      Topic.import( columns, values,
        :validate=>false,
        :on_duplicate_key_update=>columns2update,
        :synchronize=>topics )
    
      assert_equal expected_count, Topic.count, "no new records should have been created!"
      assert_equal "Jerry Carter",  topics.first.author_name, "wrong author!"
      assert_equal "Chad Fowler", topics.last.author_name, "wrong author!"
    end
  end

end