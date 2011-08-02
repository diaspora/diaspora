require File.dirname(__FILE__) + '/../spec_helper'
require 'database_cleaner/active_record/transaction'
require 'database_cleaner/data_mapper/transaction'

module DatabaseCleaner
  describe Base do

    describe "autodetect" do

       #Cache all ORMs, we'll need them later but not now.
       before(:all) do
         Temp_AR = ::ActiveRecord if defined?(::ActiveRecord) and not defined?(Temp_AR)
         Temp_DM = ::DataMapper   if defined?(::DataMapper)   and not defined?(Temp_DM)
         Temp_MM = ::MongoMapper  if defined?(::MongoMapper)  and not defined?(Temp_MM)
         Temp_MO = ::Mongoid      if defined?(::Mongoid)      and not defined?(Temp_MO)
         Temp_CP = ::CouchPotato  if defined?(::CouchPotato)  and not defined?(Temp_CP)
       end

       #Remove all ORM mocks and restore from cache
       after(:all) do
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'Mongoid')      if defined?(::Mongoid)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)


         # Restore ORMs
         ::ActiveRecord = Temp_AR if defined? Temp_AR
         ::DataMapper   = Temp_DM if defined? Temp_DM
         ::MongoMapper  = Temp_MM if defined? Temp_MM
         ::Mongoid      = Temp_MO if defined? Temp_MO
         ::CouchPotato  = Temp_CP if defined? Temp_CP
       end

       #reset the orm mocks
       before(:each) do
         Object.send(:remove_const, 'ActiveRecord') if defined?(::ActiveRecord)
         Object.send(:remove_const, 'DataMapper')   if defined?(::DataMapper)
         Object.send(:remove_const, 'MongoMapper')  if defined?(::MongoMapper)
         Object.send(:remove_const, 'Mongoid')      if defined?(::Mongoid)
         Object.send(:remove_const, 'CouchPotato')  if defined?(::CouchPotato)
       end

       let(:cleaner) { DatabaseCleaner::Base.new :autodetect }

       it "should raise an error when no ORM is detected" do
         running { cleaner }.should raise_error(DatabaseCleaner::NoORMDetected)
       end

       it "should detect ActiveRecord first" do
         Object.const_set('ActiveRecord','Actively mocking records.')
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :active_record
         cleaner.should be_auto_detected
       end

       it "should detect DataMapper second" do
         Object.const_set('DataMapper',  'Mapping data mocks')
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :data_mapper
         cleaner.should be_auto_detected
       end

       it "should detect MongoMapper third" do
         Object.const_set('MongoMapper', 'Mapping mock mongos')
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :mongo_mapper
         cleaner.should be_auto_detected
       end

       it "should detect Mongoid fourth" do
         Object.const_set('Mongoid',     'Mongoid mock')
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :mongoid
         cleaner.should be_auto_detected
       end

       it "should detect CouchPotato last" do
         Object.const_set('CouchPotato', 'Couching mock potatos')

         cleaner.orm.should == :couch_potato
         cleaner.should be_auto_detected
       end
    end

    describe "orm_module" do
      it "should ask ::DatabaseCleaner what the module is for its orm" do
        orm = mock("orm")
        mockule = mock("module")

        cleaner = ::DatabaseCleaner::Base.new
        cleaner.should_receive(:orm).and_return(orm)

        ::DatabaseCleaner.should_receive(:orm_module).with(orm).and_return(mockule)

        cleaner.send(:orm_module).should == mockule
      end
    end

    describe "comparison" do
      it "should be equal if orm, connection and strategy are the same" do
        strategy = mock("strategy")

        one = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        one.strategy = strategy

        two = DatabaseCleaner::Base.new(:active_record,:connection => :default)
        two.strategy = strategy

        one.should == two
        two.should == one
      end
    end

    describe "initialization" do
      context "db specified" do
        subject { ::DatabaseCleaner::Base.new(:active_record,:connection => :my_db) }

        it "should store db from :connection in params hash" do
          subject.db.should == :my_db
        end
      end

      describe "orm" do
        it "should store orm" do
          cleaner = ::DatabaseCleaner::Base.new :a_orm
          cleaner.orm.should == :a_orm
        end

        it "should be autodetected if orm is nil" do
          cleaner = ::DatabaseCleaner::Base.new
          cleaner.should be_auto_detected
        end

        it "should autodetect if you specify :autodetect" do
          cleaner = ::DatabaseCleaner::Base.new :autodetect
          cleaner.should be_auto_detected
        end

        it "should default to autodetect upon initalisation" do
          subject.should be_auto_detected
        end
      end
    end

    describe "db" do
      it "should default to :default" do
        subject.db.should == :default
      end

      it "should return any stored db value" do
        subject.stub(:strategy_db=)
        subject.db = :test_db
        subject.db.should == :test_db
      end

      it "should pass db to any specified strategy" do
        subject.should_receive(:strategy_db=).with(:a_new_db)
        subject.db = :a_new_db
      end
    end

    describe "strategy_db=" do
      let(:strategy) { mock("strategy") }

      before(:each) do
        subject.strategy = strategy
      end

      it "should check that strategy supports db specification" do
        strategy.should_receive(:respond_to?).with(:db=).and_return(true)
        strategy.stub(:db=)
        subject.strategy_db = :a_db
      end

      context "when strategy supports db specification" do
        before(:each) { strategy.stub(:respond_to?).with(:db=).and_return true }

        it "should pass db to the strategy" do
          strategy.should_receive(:db=).with(:a_db)
          subject.strategy_db = :a_db
        end
      end

      context "when strategy doesn't supports db specification" do
        before(:each) { strategy.stub(:respond_to?).with(:db=).and_return false }

        it "should check to see if db is :default" do
          db = mock("default")
          db.should_receive(:==).with(:default).and_return(true)

          subject.strategy_db = db
        end

        it "should raise an argument error when db isn't default" do
          db = mock("a db")
          expect{ subject.strategy_db = db }.to raise_error ArgumentError
        end
      end
    end

    describe "clean_with" do
      let (:strategy) { mock("strategy",:clean => true) }

      before(:each) { subject.stub(:create_strategy).with(anything).and_return(strategy) }

      it "should pass all arguments to create_strategy" do
        subject.should_receive(:create_strategy).with(:lorum, :dollar, :amet, :ipsum => "random").and_return(strategy)
        subject.clean_with :lorum, :dollar, :amet, { :ipsum => "random" }
      end

      it "should invoke clean on the created strategy" do
        strategy.should_receive(:clean)
        subject.clean_with :strategy
      end

      it "should return the strategy" do
        subject.clean_with( :strategy ).should == strategy
      end
    end

    describe "clean_with!" do
      let (:strategy) { mock("strategy",:clean => true) }

      before(:each) { subject.stub(:create_strategy).with(anything).and_return(strategy) }

      it "should pass all arguments to create_strategy" do
        subject.should_receive(:create_strategy).with(:lorum, :dollar, :amet, :ipsum => "random").and_return(strategy)
        subject.clean_with! :lorum, :dollar, :amet, { :ipsum => "random" }
      end

      it "should invoke clean on the created strategy" do
        strategy.should_receive(:clean)
        subject.clean_with! :strategy
      end

      it "should return the strategy" do
        subject.clean_with!( :strategy ).should == strategy
      end
    end

    describe "create_strategy" do
      let(:klass) { mock("klass",:new => mock("instance")) }

      before :each do
        subject.stub(:orm_strategy).and_return(klass)
      end

      it "should pass the first argument to orm_strategy" do
        subject.should_receive(:orm_strategy).with(:strategy).and_return(Object)
        subject.create_strategy :strategy
      end
      it "should pass the remainding argument to orm_strategy.new" do
        klass.should_receive(:new).with(:params => {:lorum => "ipsum"})

        subject.create_strategy :strategy, {:params => {:lorum => "ipsum"}}
      end
      it "should return the resulting strategy" do
        subject.create_strategy( :strategy ).should == klass.new
      end
    end

    describe "strategy=" do
      let(:mock_strategy) { mock("strategy") }

      it "should proxy symbolised strategies to create_strategy" do
        subject.should_receive(:create_strategy).with(:symbol)
        subject.strategy = :symbol
      end

      it "should proxy params with symbolised strategies" do
        subject.should_receive(:create_strategy).with(:symbol,:param => "one")
        subject.strategy= :symbol, {:param => "one"}
      end

      it "should accept strategy objects" do
        expect{ subject.strategy = mock_strategy }.to_not raise_error
      end

      it "should raise argument error when params given with strategy Object" do
        expect{ subject.strategy = mock("object"), {:param => "one"} }.to raise_error ArgumentError
      end

      it "should attempt to set strategy db" do
        subject.stub(:db).and_return(:my_db)
        subject.should_receive(:strategy_db=).with(:my_db)
        subject.strategy = mock_strategy
      end

      it "should return the stored strategy" do
        result = subject.strategy = mock_strategy
        result.should == mock_strategy
      end
    end

    describe "strategy" do
      it "should raise NoStrategySetError if strategy is nil" do
        subject.instance_values["@strategy"] = nil
        expect{ subject.strategy }.to raise_error NoStrategySetError
      end

      it "should return @strategy if @strategy is present" do
        strategum = mock("strategy")
        subject.strategy = strategum
        subject.strategy.should == strategum
      end
    end

    describe "orm=" do
      it "should stored the desired orm" do
        subject.orm.should_not == :desired_orm
        subject.orm = :desired_orm
        subject.orm.should == :desired_orm
      end
    end

    describe "orm" do
      let(:mock_orm) { mock("orm") }

      it "should return orm if orm set" do
        subject.instance_variable_set "@orm", mock_orm
        subject.orm.should == mock_orm
      end

      context "orm isn't set" do
        before(:each) { subject.instance_variable_set "@orm", nil }

        it "should run autodetect if orm isn't set" do
          subject.should_receive(:autodetect)
          subject.orm
        end

        it "should return the result of autodetect if orm isn't set" do
          subject.stub(:autodetect).and_return(mock_orm)
          subject.orm.should == mock_orm
        end
      end
    end

    describe "proxy methods" do
      let (:strategy) { mock("strategy") }

      before(:each) do
        subject.stub(:strategy).and_return(strategy)
      end

      describe "start" do
        it "should proxy start to the strategy" do
          strategy.should_receive(:start)
          subject.start
        end
      end

      describe "clean" do
        it "should proxy clean to the strategy" do
          strategy.should_receive(:clean)
          subject.clean
        end
      end

      describe "clean!" do
        it "should proxy clean! to the strategy clean" do
          strategy.should_receive(:clean)
          subject.clean!
        end
      end
    end

    describe "auto_detected?" do
      it "should return true unless @autodetected is nil" do
        subject.instance_variable_set("@autodetected","not nil")
        subject.auto_detected?.should be_true
      end

      it "should return false if @autodetect is nil" do
        subject.instance_variable_set("@autodetected",nil)
        subject.auto_detected?.should be_false
      end
    end

    describe "orm_strategy" do
      let (:klass) { mock("klass") }

      before(:each) do
        subject.stub(:orm_module).and_return(klass)
      end

      context "in response to a LoadError" do
        before(:each) { subject.should_receive(:require).with(anything).and_raise(LoadError) }

        it "should catch LoadErrors" do
          expect { subject.send(:orm_strategy,:a_strategy) }.to_not raise_error LoadError
        end

        it "should raise UnknownStrategySpecified" do
          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end

        it "should ask orm_module if it will list available_strategies" do
          klass.should_receive(:respond_to?).with(:available_strategies)

          subject.stub(:orm_module).and_return(klass)

          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end

        it "should use available_strategies (for the error message) if its available" do
          klass.stub(:respond_to?).with(:available_strategies).and_return(true)
          klass.should_receive(:available_strategies).and_return([])

          subject.stub(:orm_module).and_return(klass)

          expect { subject.send(:orm_strategy,:a_strategy) }.to raise_error UnknownStrategySpecified
        end
      end

      it "should return the constant of the Strategy class requested" do
        strategy_klass = mock("strategy klass")

        subject.stub(:require).with(anything).and_return(true)

        klass.should_receive(:const_get).with("Cunningplan").and_return(strategy_klass)

        subject.send(:orm_strategy, :cunningplan).should == strategy_klass
      end

    end

  end
end
