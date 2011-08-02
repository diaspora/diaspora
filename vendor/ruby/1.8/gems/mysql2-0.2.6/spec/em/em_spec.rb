# encoding: UTF-8
if defined? EventMachine
  require 'spec_helper'
  require 'mysql2/em'

  describe Mysql2::EM::Client do
    it "should support async queries" do
      results = []
      EM.run do
        client1 = Mysql2::EM::Client.new
        defer1 = client1.query "SELECT sleep(0.1) as first_query"
        defer1.callback do |result|
          results << result.first
          EM.stop_event_loop
        end

        client2 = Mysql2::EM::Client.new
        defer2 = client2.query "SELECT sleep(0.025) second_query"
        defer2.callback do |result|
          results << result.first
        end
      end

      results[0].keys.should include("second_query")
      results[1].keys.should include("first_query")
    end

    it "should support queries in callbacks" do
      results = []
      EM.run do
        client = Mysql2::EM::Client.new
        defer1 = client.query "SELECT sleep(0.025) as first_query"
        defer1.callback do |result|
          results << result.first
          defer2 = client.query "SELECT sleep(0.025) as second_query"
          defer2.callback do |result|
            results << result.first
            EM.stop_event_loop
          end
        end
      end

      results[0].keys.should include("first_query")
      results[1].keys.should include("second_query")
    end
  end
else
  puts "EventMachine not installed, skipping the specs that use it"
end