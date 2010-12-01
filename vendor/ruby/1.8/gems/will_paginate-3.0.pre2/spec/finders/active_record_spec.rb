require 'spec_helper'
require 'will_paginate/finders/active_record'
require File.expand_path('../activerecord_test_connector', __FILE__)
ActiverecordTestConnector.setup

WillPaginate::Finders::ActiveRecord.enable!

describe WillPaginate::Finders::ActiveRecord do
  
  extend ActiverecordTestConnector::FixtureSetup
  
  fixtures :topics, :replies, :users, :projects, :developers_projects
  
  it "should integrate with ActiveRecord::Base" do
    ActiveRecord::Base.should respond_to(:paginate)
  end
  
  it "should paginate" do
    lambda {
      users = User.paginate(:page => 1, :per_page => 5)
      users.length.should == 5
    }.should run_queries(2)
  end
  
  it "should fail when encountering unknown params" do
    lambda {
      User.paginate :foo => 'bar', :page => 1, :per_page => 4
    }.should raise_error(ArgumentError)
  end

  describe "counting" do
    it "should not accept :count parameter" do
      pending
      lambda {
        User.paginate :page => 1, :count => {}
      }.should raise_error(ArgumentError)
    end
    
    it "should guess the total count" do
      lambda {
        topics = Topic.paginate :page => 2, :per_page => 3
        topics.total_entries.should == 4
      }.should run_queries(1)
    end

    it "should guess that there are no records" do
      lambda {
        topics = Topic.where(:project_id => 999).paginate :page => 1, :per_page => 3
        topics.total_entries.should == 0
      }.should run_queries(1)
    end
  end
  
  it "should not ignore :select parameter when it says DISTINCT" do
    users = User.select('DISTINCT salary').paginate :page => 2
    users.total_entries.should == 5
  end
  
  it "should count with scoped select when :select => DISTINCT" do
    pending
    Topic.distinct.paginate :page => 2
  end

  describe "paginate_by_sql" do
    it "should respond" do
      User.should respond_to(:paginate_by_sql)
    end

    it "should paginate" do
      lambda {
        sql = "select content from topics where content like '%futurama%'"
        topics = Topic.paginate_by_sql sql, :page => 1, :per_page => 1
        topics.total_entries.should == 1
        topics.first['title'].should be_nil
      }.should run_queries(2)
    end

    it "should respect total_entries setting" do
      lambda {
        sql = "select content from topics"
        topics = Topic.paginate_by_sql sql, :page => 1, :per_page => 1, :total_entries => 999
        topics.total_entries.should == 999
      }.should run_queries(1)
    end

    it "should strip the order when counting" do
      lambda {
        sql = "select id, title, content from topics order by title"
        topics = Topic.paginate_by_sql sql, :page => 1, :per_page => 2
        topics.first.should == topics(:ar)
      }.should run_queries(2)
    end
    
    it "shouldn't change the original query string" do
      query = 'select * from topics where 1 = 2'
      original_query = query.dup
      Topic.paginate_by_sql(query, :page => 1)
      query.should == original_query
    end
  end

  it "doesn't mangle options" do
    options = { :page => 1 }
    options.expects(:delete).never
    options_before = options.dup
    
    Topic.paginate(options)
    options.should == options_before
  end
  
  it "should get first page of Topics with a single query" do
    lambda {
      result = Topic.paginate :page => nil
      result.current_page.should == 1
      result.total_pages.should == 1
      result.size.should == 4
    }.should run_queries(1)
  end
  
  it "should get second (inexistent) page of Topics, requiring 2 queries" do
    lambda {
      result = Topic.paginate :page => 2
      result.total_pages.should == 1
      result.should be_empty
    }.should run_queries(2)
  end
  
  it "should paginate with :order" do
    result = Topic.paginate :page => 1, :order => 'created_at DESC'
    result.should == topics(:futurama, :harvey_birdman, :rails, :ar).reverse
    result.total_pages.should == 1
  end
  
  it "should paginate with :conditions" do
    result = Topic.paginate :page => 1, :conditions => ["created_at > ?", 30.minutes.ago]
    result.should == topics(:rails, :ar)
    result.total_pages.should == 1
  end

  it "should paginate with :include and :conditions" do
    result = Topic.paginate \
      :page     => 1, 
      :include  => :replies,  
      :conditions => "replies.content LIKE 'Bird%' ", 
      :per_page => 10

    expected = Topic.find :all, 
      :include => 'replies', 
      :conditions => "replies.content LIKE 'Bird%' ", 
      :limit   => 10

    result.should == expected
    result.total_entries.should == 1
  end

  it "should paginate with :include and :order" do
    result = nil
    lambda {
      result = Topic.paginate \
        :page     => 1, 
        :include  => :replies,  
        :order    => 'replies.created_at asc, topics.created_at asc', 
        :per_page => 10
    }.should run_queries(2)

    expected = Topic.find :all, 
      :include => 'replies', 
      :order   => 'replies.created_at asc, topics.created_at asc', 
      :limit   => 10

    result.should == expected
    result.total_entries.should == 4
  end
  
  it "should remove :include for count" do
    lambda {
      Developer.paginate :page => 1, :per_page => 1, :include => :projects
      $query_sql.last.should_not include(' JOIN ')
    }.should run_queries(4)
  end

  it "should keep :include for count when they are referenced in :conditions" do
    Developer.expects(:find).returns([1])
    Developer.expects(:count).with({ :include => :projects, :conditions => 'projects.id > 2' }).returns(0)

    Developer.paginate :page => 1, :per_page => 1,
      :include => :projects, :conditions => 'projects.id > 2'
  end
  
  describe "associations" do
    it "should paginate with include" do
      project = projects(:active_record)

      result = project.topics.paginate \
        :page       => 1, 
        :include    => :replies,  
        :conditions => ["replies.content LIKE ?", 'Nice%'],
        :per_page   => 10

      expected = Topic.find :all, 
        :include    => 'replies', 
        :conditions => ["project_id = #{project.id} AND replies.content LIKE ?", 'Nice%'],
        :limit      => 10

      result.should == expected
    end

    it "should paginate" do
      dhh = users(:david)
      expected_name_ordered = projects(:action_controller, :active_record)
      expected_id_ordered   = projects(:active_record, :action_controller)

      lambda {
        # with association-specified order
        result = dhh.projects.paginate(:page => 1)
        result.should == expected_name_ordered
        result.total_entries.should == 2
      }.should run_queries(2)

      # with explicit order
      result = dhh.projects.paginate(:page => 1, :order => 'projects.id')
      result.should == expected_id_ordered
      result.total_entries.should == 2

      lambda {
        dhh.projects.find(:all, :order => 'projects.id', :limit => 4)
      }.should_not raise_error
      
      result = dhh.projects.paginate(:page => 1, :order => 'projects.id', :per_page => 4)
      result.should == expected_id_ordered

      # has_many with implicit order
      topic = Topic.find(1)
      expected = replies(:spam, :witty_retort)
      # FIXME: wow, this is ugly
      topic.replies.paginate(:page => 1).map(&:id).sort.should == expected.map(&:id).sort
      topic.replies.paginate(:page => 1, :order => 'replies.id ASC').should == expected.reverse
    end

    it "should paginate through association extension" do
      project = Project.find(:first)
      expected = [replies(:brave)]

      lambda {
        result = project.replies.only_recent.paginate(:page => 1)
        result.should == expected
      }.should run_queries(1)
    end
  end
  
  it "should paginate with joins" do
    result = nil
    join_sql = 'LEFT JOIN developers_projects ON users.id = developers_projects.developer_id'

    lambda {
      result = Developer.paginate :page => 1, :joins => join_sql, :conditions => 'project_id = 1'
      result.size.should == 2
      developer_names = result.map(&:name)
      developer_names.should include('David')
      developer_names.should include('Jamis')
    }.should run_queries(1)

    lambda {
      expected = result.to_a
      result = Developer.paginate :page => 1, :joins => join_sql,
                           :conditions => 'project_id = 1', :count => { :select => "users.id" }
      result.should == expected
      result.total_entries.should == 2
    }.should run_queries(1)
  end

  it "should paginate with group" do
    result = nil
    lambda {
      result = Developer.paginate :page => 1, :per_page => 10,
                                  :group => 'salary', :select => 'salary', :order => 'salary'
    }.should run_queries(1)

    expected = users(:david, :jamis, :dev_10, :poor_jamis).map(&:salary).sort
    result.map(&:salary).should == expected
  end

  it "should not paginate with dynamic finder" do
    lambda {
      Developer.paginate_by_salary(100000, :page => 1, :per_page => 5)
    }.should raise_error(NoMethodError)
  end

  it "should paginate with_scope" do
    result = Developer.with_poor_ones { Developer.paginate :page => 1 }
    result.size.should == 2
    result.total_entries.should == 2
  end

  describe "scopes" do
    it "should paginate" do
      result = Developer.poor.paginate :page => 1, :per_page => 1
      result.size.should == 1
      result.total_entries.should == 2
    end

    it "should paginate on habtm association" do
      project = projects(:active_record)
      lambda {
        result = project.developers.poor.paginate :page => 1, :per_page => 1
        result.size.should == 1
        result.total_entries.should == 1
      }.should run_queries(2)
    end

    it "should paginate on hmt association" do
      project = projects(:active_record)
      expected = [replies(:brave)]

      lambda {
        result = project.replies.recent.paginate :page => 1, :per_page => 1
        result.should == expected
        result.total_entries.should == 1
      }.should run_queries(2)
    end

    it "should paginate on has_many association" do
      project = projects(:active_record)
      expected = [topics(:ar)]

      lambda {
        result = project.topics.mentions_activerecord.paginate :page => 1, :per_page => 1
        result.should == expected
        result.total_entries.should == 1
      }.should run_queries(2)
    end
  end

  it "should paginate with :readonly option" do
    lambda {
      Developer.paginate :readonly => true, :page => 1
    }.should_not raise_error
  end
  
  it "should paginate an array of IDs" do
    lambda {
      result = Developer.paginate((1..8).to_a, :per_page => 3, :page => 2, :order => 'id')
      result.map(&:id).should == (4..6).to_a
      result.total_entries.should == 8
    }.should run_queries(1)
  end
  
  protected
  
    def run_queries(num)
      QueryCountMatcher.new(num)
    end

end

class QueryCountMatcher
  def initialize(num)
    @expected_count = num
  end

  def matches?(block)
    $query_count = 0
    $query_sql = []
    block.call
    @queries = $query_sql
    @count = $query_count
    @count == @expected_count
  end

  def failure_message
    "expected #{@expected_count} queries, got #{@count}\n#{@queries.join("\n")}"
  end

  def negative_failure_message
    "expected query count not to be #{$expected_count}"
  end
end
