require 'spec_helper'
require 'active_record'
require 'database_cleaner/active_record/base'
require 'database_cleaner/shared_strategy_spec'

module DatabaseCleaner
  describe ActiveRecord do
    it { should respond_to(:available_strategies) }

    describe "config_file_location" do
      subject { ActiveRecord.config_file_location }

      it "should default to DatabaseCleaner.root / config / database.yml" do
        DatabaseCleaner.should_receive(:app_root).and_return("/path/to")
        subject.should == '/path/to/config/database.yml'
      end
    end

  end

  module ActiveRecord
    class ExampleStrategy
      include ::DatabaseCleaner::ActiveRecord::Base
    end

    describe ExampleStrategy do

      before { ::DatabaseCleaner::ActiveRecord.stub(:config_file_location).and_return('/path/to/config/database.yml') }

      it_should_behave_like "a generic strategy"

      describe "db" do
        it { should respond_to(:db=) }

        it "should store my desired db" do
          subject.stub(:load_config)

          subject.db = :my_db
          subject.db.should == :my_db
        end

        it "should default to :default" do
          subject.db.should == :default
        end

        it "should load_config when I set db" do
          subject.should_receive(:load_config)
          subject.db = :my_db
        end
      end

      describe "load_config" do

        it { should respond_to(:load_config) }

        before do
          yaml = <<-Y
my_db:
  database: <%= "ONE".downcase %>
          Y
          IO.stub(:read).with('/path/to/config/database.yml').and_return(yaml)
        end

        it "should parse the config" do
          YAML.should_receive(:load).and_return( {:nil => nil} )
          subject.load_config
        end

        it "should process erb in the config" do
          transformed = <<-Y
my_db:
  database: one
          Y
          YAML.should_receive(:load).with(transformed).and_return({ "my_db" => {"database" => "one"} })
          subject.load_config
        end

        it "should store the relevant config in connection_hash" do
          subject.should_receive(:db).and_return(:my_db)
          subject.load_config
          subject.connection_hash.should == {"database" => "one"}
        end
      end

      describe "connection_hash" do
        it { should respond_to(:connection_hash) }
        it { should respond_to(:connection_hash=) }
        it "should store connection_hash" do
          subject.connection_hash = { :key => "value" }
          subject.connection_hash.should == { :key => "value" }
        end
      end

      describe "create_connection_klass" do
        it "should return a class" do
          subject.create_connection_klass.should be_a(Class)
        end

        it "should return a class extending ::ActiveRecord::Base" do
          subject.create_connection_klass.ancestors.should include(::ActiveRecord::Base)
        end
      end

      describe "connection_klass" do
        it { expect{ subject.connection_klass }.to_not raise_error }
        it "should default to ActiveRecord::Base" do
          subject.connection_klass.should == ::ActiveRecord::Base
        end

        context "when connection_hash is set" do
          let(:hash) { mock("hash") }
          before { subject.stub(:connection_hash).and_return(hash) }

          it "should create connection_klass if it doesnt exist if connection_hash is set" do
            subject.should_receive(:create_connection_klass).and_return(mock('class').as_null_object)
            subject.connection_klass
          end

          it  "should configure the class from create_connection_klass if connection_hash is set" do
            klass = mock('klass')
            klass.should_receive(:establish_connection).with(hash)

            subject.should_receive(:create_connection_klass).and_return(klass)
            subject.connection_klass
          end
        end
      end
    end
  end
end
