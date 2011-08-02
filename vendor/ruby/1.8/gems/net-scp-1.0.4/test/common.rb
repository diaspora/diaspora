require 'test/unit'
require 'mocha'

begin
  gem 'net-ssh', ">= 2.0.0"
  require 'net/ssh'
rescue LoadError
  $LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../../net-ssh/lib"

  begin
    require 'net/ssh'
    require 'net/ssh/version'
    raise LoadError, "wrong version" unless Net::SSH::Version::STRING >= '1.99.0'
  rescue LoadError => e
    abort "could not load net/ssh v2 (#{e.inspect})"
  end
end

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'net/scp'
require 'net/ssh/test'

class Net::SSH::Test::Channel
  def gets_ok
    gets_data "\0"
  end

  def sends_ok
    sends_data "\0"
  end
end

class Net::SCP::TestCase < Test::Unit::TestCase
  include Net::SSH::Test

  def default_test
    # do nothing, this is just a hacky-hack to work around Test::Unit's
    # insistence that all TestCase subclasses have at least one test
    # method defined.
  end

  protected

    def prepare_file(path, contents="", mode=0666, mtime=Time.now, atime=Time.now)
      entry = FileEntry.new(path, contents, mode, mtime, atime)
      entry.stub!
      entry
    end

    def prepare_directory(path, mode=0777, mtime=Time.now, atime=Time.now)
      directory = DirectoryEntry.new(path, mode, mtime, atime)
      yield directory if block_given?
      directory.stub!
    end

    # The POSIX spec unfortunately allows all characters in file names except
    # ASCII 0x00(NUL) and 0x2F(/)
    #
    # Ideally, we should be testing filenames with newlines, but Mocha doesn't
    # like this at all, so we leave them out. However, the Shellwords module
    # handles newlines just fine, so we can be reasonably confident that they
    # will work in practice
    def awful_file_name
      (((0x00..0x7f).to_a - [0x00, 0x0a, 0x2f]).map { |n| n.chr }).join + '.txt'
    end

    def escaped_file_name
      "\\\001\\\002\\\003\\\004\\\005\\\006\\\a\\\b\\\t\\\v\\\f\\\r\\\016\\\017\\\020\\\021\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\e\\\034\\\035\\\036\\\037\\ \\!\\\"\\#\\$\\%\\&\\'\\(\\)\\*\\+,-.0123456789:\\;\\<\\=\\>\\?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\\[\\\\\\]\\^_\\`abcdefghijklmnopqrstuvwxyz\\{\\|\\}\\~\\\177.txt"
    end

    class FileEntry
      attr_reader :path, :contents, :mode, :mtime, :atime, :io

      def initialize(path, contents, mode=0666, mtime=Time.now, atime=Time.now)
        @path, @contents, @mode = path, contents, mode
        @mtime, @atime = mtime, atime
      end

      def name
        @name ||= File.basename(path)
      end

      def stub!
        stat = Mocha::Mock.new("file::stat")
        stat.stubs(:size => contents.length, :mode => mode, :mtime => mtime, :atime => atime, :directory? => false)

        File.stubs(:stat).with(path).returns(stat)
        File.stubs(:directory?).with(path).returns(false)
        File.stubs(:file?).with(path).returns(true)
        File.stubs(:open).with(path, "rb").returns(StringIO.new(contents))

        @io = StringIO.new
        File.stubs(:new).with(path, "wb", mode).returns(io)
      end
    end

    class DirectoryEntry
      attr_reader :path, :mode, :mtime, :atime
      attr_reader :entries

      def initialize(path, mode=0777, mtime=Time.now, atime=Time.now)
        @path, @mode = path, mode
        @mtime, @atime = mtime, atime
        @entries = []
      end

      def name
        @name ||= File.basename(path)
      end

      def file(name, *args)
        (entries << FileEntry.new(File.join(path, name), *args)).last
      end

      def directory(name, *args)
        entry = DirectoryEntry.new(File.join(path, name), *args)
        yield entry if block_given?
        (entries << entry).last
      end

      def stub!
        Dir.stubs(:mkdir).with { |*a| a.first == path }

        stat = Mocha::Mock.new("file::stat")
        stat.stubs(:size => 1024, :mode => mode, :mtime => mtime, :atime => atime, :directory? => true)

        File.stubs(:stat).with(path).returns(stat)
        File.stubs(:directory?).with(path).returns(true)
        File.stubs(:file?).with(path).returns(false)
        Dir.stubs(:entries).with(path).returns(%w(. ..) + entries.map { |e| e.name }.sort)

        entries.each { |e| e.stub! }
      end
    end

    def expect_scp_session(arguments)
      story do |session|
        channel = session.opens_channel
        channel.sends_exec "scp #{arguments}"
        yield channel if block_given?
        channel.sends_eof
        channel.gets_exit_status
        channel.gets_eof
        channel.gets_close
        channel.sends_close
      end
    end

    def scp(options={})
      @scp ||= Net::SCP.new(connection(options))
    end
end
