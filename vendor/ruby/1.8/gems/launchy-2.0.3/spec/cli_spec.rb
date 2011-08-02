require 'spec_helper'

describe Launchy::Cli do

  before do
    @old_stderr = $stderr
    $stderr = StringIO.new

    @old_stdout = $stdout
    $stdout = StringIO.new
    Launchy.reset_global_options
  end

  after do
    Launchy.reset_global_options
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  def cli_test( argv, env, exit_val, stderr_regex, stdout_regex )
    begin
      Launchy::Cli.new.run( argv, env )
    rescue SystemExit => se
      se.status.must_equal exit_val
      $stderr.string.must_match stderr_regex if stderr_regex
      $stdout.string.must_match stdout_regex if stdout_regex
    end
  end

  it "exits 1 when invalid options are given" do
    cli_test( %w[ -z foo ], {}, 1, /invalid option/, nil )
  end

  %w[ -h --help ].each do |opt|
    it "output help and exits 0 when using #{opt}" do
      cli_test( [ opt ], {}, 0, nil, /Print this message/m )
    end
  end

  %w[ -v --version ].each do |opt|
    it "outputs version and exits 0 when using #{opt}" do
      cli_test( [ opt ], {}, 0, nil, /Launchy version/ )
    end
  end

  it "leaves the url on argv after parsing" do
    l = Launchy::Cli.new
    argv = %w[ --debug --dry-run http://github.com/copiousfreetime/launchy ]
    l.parse( argv , {} )
    argv.size.must_equal 1
    argv[0].must_equal "http://github.com/copiousfreetime/launchy" 
  end

  it "prints the command on stdout when using --dry-run" do
   argv = %w[ --debug --dry-run http://github.com/copiousfreetime/launchy ]
   rc = Launchy::Cli.new.good_run( argv, {} )
   $stdout.string.must_match %r[github.com]
  end

  {
    '--application' => [ :application, 'Browser'],
    '--engine'      => [ :ruby_engine, 'rbx'],
    '--host-os'     => [ :host_os,     'cygwin'] }.each_pair do |opt, val|
    it "the commandline option #{opt} sets the program option #{val[0]}" do
      argv = [ opt, val[1], "http://github.com/copiousfreetime/launchy" ]
      l = Launchy::Cli.new
      rc = l.parse( argv, {} )
      rc.must_equal true
      argv.size.must_equal 1
      argv[0].must_equal "http://github.com/copiousfreetime/launchy"
      l.options[val[0]].must_equal val[1]
    end
  end
end
 
