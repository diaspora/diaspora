#This is a spec for the class that runs the servers used in the other multi-server specs

require 'spec_helper'
unless Server.all.empty?
  describe Server do
    before(:all) do
      Server.start
    end

    after(:all) do
      Server.stop
    end

    before do
      Server.truncate_databases
    end
    describe '.all' do
      it 'returns a server object for each server' do
        integration_envs = ActiveRecord::Base.configurations.keys.select{ |k| k.include?("integration") }
        integration_envs.count.should == Server.all.count
      end
    end
    describe '#initialize' do
      it 'takes an environment' do
        server = Server.new("integration_1")
        server.env.should == "integration_1"
      end
    end
    describe "#running?" do
      it "verifies that the server is running" do
        server = Server.new("integration_1")
        server.running?.should be_true
      end
    end
    describe '#db' do
      it 'runs the given code in the context of that server' do
        servers = Server.all

        test_user_count = User.count
        servers.first.db do
          User.count.should == 0
          Factory :user
          User.count.should == 1
        end
        User.count.should == test_user_count

        servers.last.db do
          User.count.should == 0
        end
      end
    end
  end
end
