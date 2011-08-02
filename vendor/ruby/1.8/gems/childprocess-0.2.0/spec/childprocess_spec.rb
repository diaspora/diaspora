require File.expand_path('../spec_helper', __FILE__)

describe ChildProcess do

  EXIT_TIMEOUT = 10

  it "returns self when started" do
    process = sleeping_ruby

    process.start.should == process
    process.should be_started
  end

  it "knows if the process crashed" do
    process = exit_with(1).start
    process.poll_for_exit(EXIT_TIMEOUT)

    process.should be_crashed
  end

  it "knows if the process didn't crash" do
    process = exit_with(0).start
    process.poll_for_exit(EXIT_TIMEOUT)

    process.should_not be_crashed
  end

  it "escalates if TERM is ignored" do
    process = ignored('TERM').start
    process.stop
    process.should be_exited
  end

  it "accepts a timeout argument to #stop" do
    process = sleeping_ruby.start
    process.stop(EXIT_TIMEOUT)
  end

  it "lets child process inherit the environment of the current process" do
    Tempfile.open("env-spec") do |file|
      with_env('INHERITED' => 'yes') do
        process = write_env(file.path).start
        process.poll_for_exit(EXIT_TIMEOUT)
      end

      file.rewind
      child_env = eval(file.read)
      child_env['INHERITED'].should == 'yes'
    end
  end

  it "passes arguments to the child" do
    args = ["foo", "bar"]

    Tempfile.open("argv-spec") do |file|
      process = write_argv(file.path, *args).start
      process.poll_for_exit(EXIT_TIMEOUT)

      file.rewind
      file.read.should == args.inspect
    end
  end

  it "lets a detached child live on" do
    pending "how do we spec this?"
  end

  it "can redirect stdout, stderr" do
    process = ruby(<<-CODE)
      [STDOUT, STDERR].each_with_index do |io, idx|
        io.sync = true
        io.puts idx
      end

      sleep 0.2
    CODE

    out = Tempfile.new("stdout-spec")
    err = Tempfile.new("stderr-spec")

    begin
      process.io.stdout = out
      process.io.stderr = err

      process.start
      process.io.stdin.should be_nil
      process.poll_for_exit(EXIT_TIMEOUT)

      out.rewind
      err.rewind

      out.read.should == "0\n"
      err.read.should == "1\n"
    ensure
      out.close
      err.close
    end
  end

  it "can write to stdin if duplex = true" do
    process = ruby(<<-CODE)
      puts(STDIN.gets.chomp)
    CODE

    out = Tempfile.new("duplex")

    begin
      process.io.stdout = out
      process.io.stderr = out
      process.duplex = true

      process.start
      process.io.stdin.puts "hello world"
      process.io.stdin.close # JRuby seems to need this

      process.poll_for_exit(EXIT_TIMEOUT)

      out.rewind
      out.read.should == "hello world\n"
    ensure
      out.close
    end
  end

  it "can set close-on-exec when IO is inherited" do
    server = TCPServer.new("localhost", 4433)
    ChildProcess.close_on_exec server

    process = sleeping_ruby
    process.io.inherit!

    process.start
    sleep 0.5 # give the forked process a chance to exec() (which closes the fd)

    server.close
    lambda { TCPServer.new("localhost", 4433).close }.should_not raise_error
  end

  it "preserves Dir.pwd in the child" do
    require 'pathname'
    begin
      path = nil
      Tempfile.open("dir-spec") {|tf| path = tf.path }
      path = Pathname.new(path).realpath.to_s
      File.unlink(path)
      Dir.mkdir(path)
      Dir.chdir(path) do
        process = ruby("puts Dir.pwd")
        begin
          out = Tempfile.new("dir-spec-out")

          process.io.stdout = out
          process.io.stderr = out

          process.start
          process.poll_for_exit(EXIT_TIMEOUT)

          out.rewind
          out.read.should == "#{path}\n"
        ensure
          out.close
        end
      end
    ensure
      Dir.rmdir(path) if File.exist?(path)
    end
  end

  it "can handle whitespace, special characters and quotes in arguments" do
    args = ["foo bar", 'foo\bar', "'i-am-quoted'", '"i am double quoted"']

    Tempfile.open("argv-spec") do |file|
      process = write_argv(file.path, *args).start
      process.poll_for_exit(EXIT_TIMEOUT)

      file.rewind
      file.read.should == args.inspect
    end
  end

end
