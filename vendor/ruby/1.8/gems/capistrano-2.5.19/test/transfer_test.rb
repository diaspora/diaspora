require 'utils'
require 'capistrano/transfer'

class TransferTest < Test::Unit::TestCase
  def test_class_process_should_delegate_to_instance_process
    Capistrano::Transfer.expects(:new).with(:up, "from", "to", %w(a b c), {}).returns(mock('transfer', :process! => nil)).yields
    yielded = false
    Capistrano::Transfer.process(:up, "from", "to", %w(a b c), {}) { yielded = true }
    assert yielded
  end

  def test_default_transport_is_sftp
    transfer = Capistrano::Transfer.new(:up, "from", "to", [])
    assert_equal :sftp, transfer.transport
  end

  def test_active_is_true_when_any_sftp_transfers_are_active
    returns = [false, false, true]
    sessions = [session('app1', :sftp), session('app2', :sftp), session('app3', :sftp)].each { |s| s.xsftp.expects(:upload).returns(stub('operation', :active? => returns.shift)) }
    transfer = Capistrano::Transfer.new(:up, "from", "to", sessions, :via => :sftp)
    assert_equal true, transfer.active?
  end

  def test_active_is_false_when_all_sftp_transfers_are_not_active
    sessions = [session('app1', :sftp), session('app2', :sftp)].each { |s| s.xsftp.expects(:upload).returns(stub('operation', :active? => false)) }
    transfer = Capistrano::Transfer.new(:up, "from", "to", sessions, :via => :sftp)
    assert_equal false, transfer.active?
  end

  def test_active_is_true_when_any_scp_transfers_are_active
    returns = [false, false, true]
    sessions = [session('app1', :scp), session('app2', :scp), session('app3', :scp)].each do |s|
      channel = stub('channel', :[]= => nil, :active? => returns.shift)
      s.scp.expects(:upload).returns(channel)
    end
    transfer = Capistrano::Transfer.new(:up, "from", "to", sessions, :via => :scp)
    assert_equal true, transfer.active?
  end

  def test_active_is_false_when_all_scp_transfers_are_not_active
    sessions = [session('app1', :scp), session('app2', :scp), session('app3', :scp)].each do |s|
      channel = stub('channel', :[]= => nil, :active? => false)
      s.scp.expects(:upload).returns(channel)
    end
    transfer = Capistrano::Transfer.new(:up, "from", "to", sessions, :via => :scp)
    assert_equal false, transfer.active?
  end

  [:up, :down].each do |direction|
    define_method("test_sftp_#{direction}load_from_file_to_file_should_normalize_from_and_to") do
      sessions = [session('app1', :sftp), session('app2', :sftp)]

      sessions.each do |session|
        session.xsftp.expects("#{direction}load".to_sym).with("from-#{session.xserver.host}", "to-#{session.xserver.host}",
          :properties => { :server => session.xserver, :host => session.xserver.host })
      end

      transfer = Capistrano::Transfer.new(direction, "from-$CAPISTRANO:HOST$", "to-$CAPISTRANO:HOST$", sessions)
    end

    define_method("test_scp_#{direction}load_from_file_to_file_should_normalize_from_and_to") do
      sessions = [session('app1', :scp), session('app2', :scp)]

      sessions.each do |session|
        session.scp.expects("#{direction}load".to_sym).returns({}).with("from-#{session.xserver.host}", "to-#{session.xserver.host}", :via => :scp)
      end

      transfer = Capistrano::Transfer.new(direction, "from-$CAPISTRANO:HOST$", "to-$CAPISTRANO:HOST$", sessions, :via => :scp)
    end
  end

  def test_sftp_upload_from_IO_to_file_should_clone_the_IO_for_each_connection
    sessions = [session('app1', :sftp), session('app2', :sftp)]
    io = StringIO.new("from here")

    sessions.each do |session|
      session.xsftp.expects(:upload).with do |from, to, opts|
        from != io && from.is_a?(StringIO) && from.string == io.string &&
        to == "/to/here-#{session.xserver.host}" &&
        opts[:properties][:server] == session.xserver &&
        opts[:properties][:host] == session.xserver.host
      end
    end

    transfer = Capistrano::Transfer.new(:up, StringIO.new("from here"), "/to/here-$CAPISTRANO:HOST$", sessions)
  end

  def test_scp_upload_from_IO_to_file_should_clone_the_IO_for_each_connection
    sessions = [session('app1', :scp), session('app2', :scp)]
    io = StringIO.new("from here")

    sessions.each do |session|
      channel = mock('channel')
      channel.expects(:[]=).with(:server, session.xserver)
      channel.expects(:[]=).with(:host, session.xserver.host)
      session.scp.expects(:upload).returns(channel).with do |from, to, opts|
        from != io && from.is_a?(StringIO) && from.string == io.string &&
        to == "/to/here-#{session.xserver.host}"
      end
    end

    transfer = Capistrano::Transfer.new(:up, StringIO.new("from here"), "/to/here-$CAPISTRANO:HOST$", sessions, :via => :scp)
  end

  def test_process_should_block_until_transfer_is_no_longer_active
    transfer = Capistrano::Transfer.new(:up, "from", "to", [])
    transfer.expects(:process_iteration).times(4).yields.returns(true,true,true,false)
    transfer.expects(:active?).times(4)
    transfer.process!
  end

  def test_errors_raised_for_a_sftp_session_should_abort_session_and_continue_with_remaining_sessions
    s = session('app1')
    error = ExceptionWithSession.new(s)
    transfer = Capistrano::Transfer.new(:up, "from", "to", [])
    transfer.expects(:process_iteration).raises(error).times(3).returns(true, false)
    txfr = mock('transfer', :abort! => true)
    txfr.expects(:[]=).with(:failed, true)
    txfr.expects(:[]=).with(:error, error)
    transfer.expects(:session_map).returns(s => txfr)
    transfer.process!
  end

  def test_errors_raised_for_a_scp_session_should_abort_session_and_continue_with_remaining_sessions
    s = session('app1')
    error = ExceptionWithSession.new(s)
    transfer = Capistrano::Transfer.new(:up, "from", "to", [], :via => :scp)
    transfer.expects(:process_iteration).raises(error).times(3).returns(true, false)
    txfr = mock('channel', :close => true)
    txfr.expects(:[]=).with(:failed, true)
    txfr.expects(:[]=).with(:error, error)
    transfer.expects(:session_map).returns(s => txfr)
    transfer.process!
  end

  private

    class ExceptionWithSession < ::Exception
      attr_reader :session

      def initialize(session)
        @session = session
        super()
      end
    end

    def session(host, mode=nil)
      session = stub('session', :xserver => stub('server', :host => host))
      case mode
      when :sftp
        sftp = stub('sftp')
        session.expects(:sftp).with(false).returns(sftp)
        sftp.expects(:connect).yields(sftp).returns(sftp)
        session.stubs(:xsftp).returns(sftp)
      when :scp
        session.stubs(:scp).returns(stub('scp'))
      end
      session
    end
end