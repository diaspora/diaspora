require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module SeleniumRC
  describe Server do

    def new_server(*args)
      server = Server.new(*args)
      stub(server).log
      stub(server).fork.yields
      server
    end

    describe "#start" do
      it "launches java with the jar file and port" do
        @server = new_server("0.0.0.0", 5555)

        expected_command = %Q{java -jar "/path/to/the.jar" -port 5555}
        mock(@server).system(expected_command)
        mock(@server).jar_path {"/path/to/the.jar"}
        @server.start
      end

      context "when passed additional arguments" do
        it "adds the additional arguments to the selenium start command" do
          @server = new_server("0.0.0.0", 4444, :args => ["-browserSideLog", "-suppressStupidness"])
          expected_command = %Q{java -jar "/path/to/the.jar" -port 4444 -browserSideLog -suppressStupidness}
          mock(@server).system(expected_command)
          mock(@server).jar_path {"/path/to/the.jar"}
          @server.start
        end
      end
    end
  end
end
