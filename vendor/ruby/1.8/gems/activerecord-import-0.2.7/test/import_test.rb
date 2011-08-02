require File.expand_path('../test_helper', __FILE__)

describe "#import" do
  it "should return the number of inserts performed" do
    # see ActiveRecord::ConnectionAdapters::AbstractAdapter test for more specifics
    assert_difference "Topic.count", +10 do
      result = Topic.import Build(3, :topics)
      assert result.num_inserts > 0
    
      result = Topic.import Build(7, :topics)
      assert result.num_inserts > 0
    end
  end

  it "should not produce an error when importing empty arrays" do
    assert_nothing_raised do
      Topic.import []
      Topic.import %w(title author_name), []
    end
  end

  context "with :validation option" do
    let(:columns) { %w(title author_name) }
    let(:valid_values) { [[ "LDAP", "Jerry Carter"], ["Rails Recipes", "Chad Fowler"]] }
    let(:invalid_values) { [[ "The RSpec Book", ""], ["Agile+UX", ""]] }
  
    context "with validation checks turned off" do
      it "should import valid data" do
        assert_difference "Topic.count", +2 do
          result = Topic.import columns, valid_values, :validate => false
        end
      end
  
      it "should import invalid data" do
        assert_difference "Topic.count", +2 do
          result = Topic.import columns, invalid_values, :validate => false
        end
      end
    end
  
    context "with validation checks turned on" do
      it "should import valid data" do
        assert_difference "Topic.count", +2 do
          result = Topic.import columns, valid_values, :validate => true
        end
      end
  
      it "should not import invalid data" do
        assert_no_difference "Topic.count" do
          result = Topic.import columns, invalid_values, :validate => true
        end
      end
  
      it "should report the failed instances" do
        results = Topic.import columns, invalid_values, :validate => true
        assert_equal invalid_values.size, results.failed_instances.size
        results.failed_instances.each{ |e| assert_kind_of Topic, e }
      end
  
      it "should import valid data when mixed with invalid data" do
        assert_difference "Topic.count", +2 do
          result = Topic.import columns, valid_values + invalid_values, :validate => true
        end
        assert_equal 0, Topic.find_all_by_title(invalid_values.map(&:first)).count
      end
    end
  end
  
  context "with :synchronize option" do
    context "synchronizing on new records" do
      let(:new_topics) { Build(3, :topics) }
    
      it "doesn't reload any data (doesn't work)" do
        Topic.import new_topics, :synchronize => new_topics
        assert new_topics.all?(&:new_record?), "No record should have been reloaded"
      end
    end
    
    context "synchronizing on new records with explicit conditions" do
      let(:new_topics) { Build(3, :topics) }

      it "reloads data for existing in-memory instances" do
        Topic.import(new_topics, :synchronize => new_topics, :synchronize_key => [:title] )
        assert new_topics.all?(&:new_record?), "Records should have been reloaded"
      end      
    end
  end
  
  context "with an array of unsaved model instances" do
    let(:topic) { Build(:topic, :title => "The RSpec Book", :author_name => "David Chelimsky")}
    let(:topics) { Build(9, :topics) }
    let(:invalid_topics){ Build(7, :invalid_topics)}
    
    it "should import records based on those model's attributes" do
      assert_difference "Topic.count", +9 do
        result = Topic.import topics
      end
      
      Topic.import [topic]
      assert Topic.find_by_title_and_author_name("The RSpec Book", "David Chelimsky")
    end
  
    it "should not overwrite existing records" do
      topic = Generate(:topic, :title => "foobar")
      assert_no_difference "Topic.count" do
        begin
          Topic.transaction do
            topic.title = "baz"
            Topic.import [topic]
          end
        rescue Exception
          # PostgreSQL raises PgError due to key constraints
          # I don't know why ActiveRecord doesn't catch these. *sigh*
        end
      end
      assert_equal "foobar", topic.reload.title
    end
    
    context "with validation checks turned on" do
      it "should import valid models" do
        assert_difference "Topic.count", +9 do
          result = Topic.import topics, :validate => true
        end
      end
      
      it "should not import invalid models" do
        assert_no_difference "Topic.count" do
          result = Topic.import invalid_topics, :validate => true
        end
      end
    end
    
    context "with validation checks turned off" do
      it "should import invalid models" do
        assert_difference "Topic.count", +7 do
          result = Topic.import invalid_topics, :validate => false
        end
      end
    end
  end
  
  context "with an array of columns and an array of unsaved model instances" do
    let(:topics) { Build(2, :topics) }
    
    it "should import records populating the supplied columns with the corresponding model instance attributes" do
      assert_difference "Topic.count", +2 do
        result = Topic.import [:author_name, :title], topics
      end
      
      # imported topics should be findable by their imported attributes
      assert Topic.find_by_author_name(topics.first.author_name)
      assert Topic.find_by_author_name(topics.last.author_name)
    end
  
    it "should not populate fields for columns not imported" do
      topics.first.author_email_address = "zach.dennis@gmail.com"
      assert_difference "Topic.count", +2 do
        result = Topic.import [:author_name, :title], topics
      end
      
      assert !Topic.find_by_author_email_address("zach.dennis@gmail.com")
    end
  end
  
  context "with an array of columns and an array of values" do
    it "should import ids when specified" do
      Topic.import [:id, :author_name, :title], [[99, "Bob Jones", "Topic 99"]]
      assert_equal 99, Topic.last.id
    end
  end
  
  context "ActiveRecord timestamps" do
    context "when the timestamps columns are present" do
      setup do
        Delorean.time_travel_to("5 minutes ago") do
          assert_difference "Book.count", +1 do
            result = Book.import [:title, :author_name, :publisher], [["LDAP", "Big Bird", "Del Rey"]]
          end
        end
        @book = Book.last
      end
    
      it "should set the created_at column for new records"  do
        assert_equal 5.minutes.ago.strftime("%H:%M"), @book.created_at.strftime("%H:%M")
      end
  
      it "should set the created_on column for new records" do
        assert_equal 5.minutes.ago.strftime("%H:%M"), @book.created_on.strftime("%H:%M")
      end
  
      it "should set the updated_at column for new records" do
        assert_equal 5.minutes.ago.strftime("%H:%M"), @book.updated_at.strftime("%H:%M")
      end
  
      it "should set the updated_on column for new records" do
        assert_equal 5.minutes.ago.strftime("%H:%M"), @book.updated_on.strftime("%H:%M")
      end
    end
    
    context "when a custom time zone is set" do
      setup do
        original_timezone = ActiveRecord::Base.default_timezone
        ActiveRecord::Base.default_timezone = :utc
        Delorean.time_travel_to("5 minutes ago") do
          assert_difference "Book.count", +1 do
            result = Book.import [:title, :author_name, :publisher], [["LDAP", "Big Bird", "Del Rey"]]
          end
        end
        ActiveRecord::Base.default_timezone = original_timezone
        @book = Book.last
      end
  
      it "should set the created_at and created_on timestamps for new records"  do
        assert_equal 5.minutes.ago.utc.strftime("%H:%M"), @book.created_at.strftime("%H:%M")
        assert_equal 5.minutes.ago.utc.strftime("%H:%M"), @book.created_on.strftime("%H:%M")
      end
  
      it "should set the updated_at and updated_on timestamps for new records" do
        assert_equal 5.minutes.ago.utc.strftime("%H:%M"), @book.updated_at.strftime("%H:%M")
        assert_equal 5.minutes.ago.utc.strftime("%H:%M"), @book.updated_on.strftime("%H:%M")
      end
    end
  end
  
  context "importing with database reserved words" do
    let(:group) { Build(:group, :order => "superx") }
    
    it "should import just fine" do
      assert_difference "Group.count", +1 do
        result = Group.import [group]
      end
      assert_equal "superx", Group.first.order
    end
  end

  context "importing a datetime field" do
    it "should import a date with MM/DD/YYYY format just fine" do
      Topic.import [:author_name, :title, :last_read], [["Bob Jones", "Topic 1", "05/14/2010"]]
      assert_equal "05/14/2010".to_date, Topic.last.last_read.to_date
    end

    it "should import a date with YYYY/MM/DD format just fine" do
      Topic.import [:author_name, :title, :last_read], [["Bob Jones", "Topic 2", "2010/05/14"]]
      assert_equal "05/14/2010".to_date, Topic.last.last_read.to_date
    end
  end
end