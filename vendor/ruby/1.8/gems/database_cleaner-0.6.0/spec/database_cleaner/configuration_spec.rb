require File.dirname(__FILE__) + '/../spec_helper'

module DatabaseCleaner
  class << self
    def reset
      @connections = nil
    end

    def connections_stub!(array)
      @connections = array
    end
  end
end

describe ::DatabaseCleaner do
  before(:each) { ::DatabaseCleaner.reset }

  context "orm specification" do
    it "should not accept unrecognised orms" do
      expect { ::DatabaseCleaner[nil] }.should raise_error(::DatabaseCleaner::NoORMDetected)
    end

    it "should accept :active_record" do
      cleaner = ::DatabaseCleaner[:active_record]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should == :active_record
      ::DatabaseCleaner.connections.size.should == 1
    end

    it "should accept :data_mapper" do
      cleaner = ::DatabaseCleaner[:data_mapper]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should == :data_mapper
      ::DatabaseCleaner.connections.size.should == 1
    end

    it "should accept :mongo_mapper" do
      cleaner = ::DatabaseCleaner[:mongo_mapper]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should == :mongo_mapper
      ::DatabaseCleaner.connections.size.should == 1
    end

    it "should accept :couch_potato" do
      cleaner = ::DatabaseCleaner[:couch_potato]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should == :couch_potato
      ::DatabaseCleaner.connections.size.should == 1
    end
  end

  it "should accept multiple orm's" do
    ::DatabaseCleaner[:couch_potato]
    ::DatabaseCleaner[:data_mapper]
    ::DatabaseCleaner.connections.size.should == 2
    ::DatabaseCleaner.connections[0].orm.should == :couch_potato
    ::DatabaseCleaner.connections[1].orm.should == :data_mapper
  end

  context "connection/db specification" do
    it "should accept a connection parameter and store it" do
      cleaner = ::DatabaseCleaner[:active_record, {:connection => :first_connection}]
      cleaner.should be_a(::DatabaseCleaner::Base)
      cleaner.orm.should == :active_record
      cleaner.db.should == :first_connection
    end

    it "should accept multiple connections for a single orm" do
      ::DatabaseCleaner[:data_mapper,{:connection => :first_db}]
      ::DatabaseCleaner[:data_mapper,{:connection => :second_db}]
      ::DatabaseCleaner.connections.size.should == 2
      ::DatabaseCleaner.connections[0].orm.should == :data_mapper
      ::DatabaseCleaner.connections[0].db.should  == :first_db
      ::DatabaseCleaner.connections[1].orm.should == :data_mapper
      ::DatabaseCleaner.connections[1].db.should  == :second_db
    end

    it "should accept multiple connections and multiple orms" do
      ::DatabaseCleaner[:data_mapper,  {:connection => :first_db} ]
      ::DatabaseCleaner[:active_record,{:connection => :second_db}]
      ::DatabaseCleaner[:active_record,{:connection => :first_db} ]
      ::DatabaseCleaner[:data_mapper,  {:connection => :second_db}]

      ::DatabaseCleaner.connections.size.should == 4

      ::DatabaseCleaner.connections[0].orm.should == :data_mapper
      ::DatabaseCleaner.connections[0].db.should  == :first_db

      ::DatabaseCleaner.connections[1].orm.should == :active_record
      ::DatabaseCleaner.connections[1].db.should  == :second_db

      ::DatabaseCleaner.connections[2].orm.should == :active_record
      ::DatabaseCleaner.connections[2].db.should  == :first_db

      ::DatabaseCleaner.connections[3].orm.should == :data_mapper
      ::DatabaseCleaner.connections[3].db.should  == :second_db
    end
  end

  context "connection/db retrieval" do
    it "should retrieve a db rather than create a new one" do
      pending
      connection = ::DatabaseCleaner[:active_record].strategy = :truncation
      ::DatabaseCleaner[:active_record].should == connection
    end
  end

  context "class methods" do
    subject { ::DatabaseCleaner }

    its(:connections) { should respond_to(:each) }

    it "should give me a default (autodetection) databasecleaner by default" do
      cleaner = mock("cleaner").as_null_object
      ::DatabaseCleaner::Base.should_receive(:new).with().and_return(cleaner)

      ::DatabaseCleaner.connections.should have(1).items
      ::DatabaseCleaner.connections.first.should == cleaner
    end
  end

  context "single orm single connection" do
    let(:connection) { ::DatabaseCleaner.connections.first }

    it "should proxy strategy=" do
      stratagum = mock("stratagum")
      connection.should_receive(:strategy=).with(stratagum)
      ::DatabaseCleaner.strategy = stratagum
    end

    it "should proxy orm=" do
      orm = mock("orm")
      connection.should_receive(:orm=).with(orm)
      ::DatabaseCleaner.orm = orm
    end

    it "should proxy start" do
      connection.should_receive(:start)
      ::DatabaseCleaner.start
    end

    it "should proxy clean" do
      connection.should_receive(:clean)
      ::DatabaseCleaner.clean
    end

    it "should proxy clean_with" do
      stratagem = mock("stratgem")
      connection.should_receive(:clean_with).with(stratagem, {})
      ::DatabaseCleaner.clean_with stratagem, {}
    end
  end

  context "multiple connections" do

    #these are relativly simple, all we need to do is make sure all connections are cleaned/started/cleaned_with appropriatly.
    context "simple proxy methods" do

      let(:active_record) { mock("active_mock") }
      let(:data_mapper)   { mock("data_mock")   }

      before(:each) do
        ::DatabaseCleaner.stub!(:connections).and_return([active_record,data_mapper])
      end

      it "should proxy orm to all connections" do
        active_record.should_receive(:orm=)
        data_mapper.should_receive(:orm=)

        ::DatabaseCleaner.orm = mock("orm")
      end

      it "should proxy start to all connections" do
        active_record.should_receive(:start)
        data_mapper.should_receive(:start)

        ::DatabaseCleaner.start
      end

      it "should proxy clean to all connections" do
        active_record.should_receive(:clean)
        data_mapper.should_receive(:clean)

        ::DatabaseCleaner.clean
      end

      it "should proxy clean_with to all connections" do
        stratagem = mock("stratgem")
        active_record.should_receive(:clean_with).with(stratagem)
        data_mapper.should_receive(:clean_with).with(stratagem)

        ::DatabaseCleaner.clean_with stratagem
      end
    end

    # ah now we have some difficulty, we mustn't allow duplicate connections to exist, but they could
    # plausably want to force orm/strategy change on two sets of orm that differ only on db
    context "multiple orm proxy methods" do

      it "should proxy orm to all connections and remove duplicate connections" do
        active_record_1 = mock("active_mock_on_db_one").as_null_object
        active_record_2 = mock("active_mock_on_db_two").as_null_object
        data_mapper_1   = mock("data_mock_on_db_one").as_null_object

        ::DatabaseCleaner.connections_stub! [active_record_1,active_record_2,data_mapper_1]

        active_record_1.should_receive(:orm=).with(:data_mapper)
        active_record_2.should_receive(:orm=).with(:data_mapper)
        data_mapper_1.should_receive(:orm=).with(:data_mapper)

        active_record_1.should_receive(:==).with(data_mapper_1).and_return(true)

        ::DatabaseCleaner.connections.size.should == 3
        ::DatabaseCleaner.orm = :data_mapper
        ::DatabaseCleaner.connections.size.should == 2
      end

      it "should proxy strategy to all connections and remove duplicate connections" do
        active_record_1 = mock("active_mock_strategy_one").as_null_object
        active_record_2 = mock("active_mock_strategy_two").as_null_object
        strategy = mock("strategy")

        ::DatabaseCleaner.connections_stub! [active_record_1,active_record_2]

        active_record_1.should_receive(:strategy=).with(strategy)
        active_record_2.should_receive(:strategy=).with(strategy)

        active_record_1.should_receive(:==).with(active_record_2).and_return(true)

        ::DatabaseCleaner.connections.size.should == 2
        ::DatabaseCleaner.strategy = strategy
        ::DatabaseCleaner.connections.size.should == 1
      end
    end
  end

  describe "remove_duplicates" do
    it "should remove duplicates if they are identical" do
      orm = mock("orm")
      connection = mock("a datamapper connection", :orm => orm )

      ::DatabaseCleaner.connections_stub!  [connection,connection,connection]

      ::DatabaseCleaner.remove_duplicates
      ::DatabaseCleaner.connections.size.should == 1
    end
  end

  describe "app_root" do
    it "should default to Dir.pwd" do
      DatabaseCleaner.app_root.should == Dir.pwd
    end

    it "should store specific paths" do
      DatabaseCleaner.app_root = '/path/to'
      DatabaseCleaner.app_root.should == '/path/to'
    end
  end

  describe "orm_module" do
    subject { ::DatabaseCleaner }

    it "should return DatabaseCleaner::ActiveRecord for :active_record" do
      ::DatabaseCleaner::ActiveRecord = mock("ar module") unless defined? ::DatabaseCleaner::ActiveRecord
      subject.orm_module(:active_record).should == DatabaseCleaner::ActiveRecord
    end

    it "should return DatabaseCleaner::DataMapper for :data_mapper" do
      ::DatabaseCleaner::DataMapper = mock("dm module") unless defined? ::DatabaseCleaner::DataMapper
      subject.orm_module(:data_mapper).should == DatabaseCleaner::DataMapper
    end

    it "should return DatabaseCleaner::MongoMapper for :mongo_mapper" do
      ::DatabaseCleaner::MongoMapper = mock("mm module") unless defined? ::DatabaseCleaner::MongoMapper
      subject.orm_module(:mongo_mapper).should == DatabaseCleaner::MongoMapper
    end

    it "should return DatabaseCleaner::Mongoid for :mongoid" do
      ::DatabaseCleaner::Mongoid = mock("mongoid module") unless defined? ::DatabaseCleaner::Mongoid
      subject.orm_module(:mongoid).should == DatabaseCleaner::Mongoid
    end

    it "should return DatabaseCleaner::Mongo for :mongo" do
      ::DatabaseCleaner::Mongo = mock("mongo module") unless defined? ::DatabaseCleaner::Mongo
      subject.orm_module(:mongo).should == DatabaseCleaner::Mongo
    end

    it "should return DatabaseCleaner::CouchPotato for :couch_potato" do
      ::DatabaseCleaner::CouchPotato = mock("cp module") unless defined? ::DatabaseCleaner::CouchPotato
      subject.orm_module(:couch_potato).should == DatabaseCleaner::CouchPotato
    end

  end
end
