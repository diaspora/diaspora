begin
  require 'rubygems'
  require 'redgreen' unless ENV['TM_FILENAME']
  gem     'mocha'
rescue LoadError
end

require 'test/unit'
require 'mocha'
require 'capistrano/server_definition'

module TestExtensions
  def server(host, options={})
    Capistrano::ServerDefinition.new(host, options)
  end

  def namespace(fqn=nil)
    space = stub(:roles => {}, :fully_qualified_name => fqn, :default_task => nil)
    yield(space) if block_given?
    space
  end

  def role(space, name, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    space.roles[name] ||= []
    space.roles[name].concat(args.map { |h| Capistrano::ServerDefinition.new(h, opts) })
  end

  def new_task(name, namespace=@namespace, options={}, &block)
    block ||= Proc.new {}
    task = Capistrano::TaskDefinition.new(name, namespace, options, &block)
    assert_equal block, task.body
    return task
  end
end

class Test::Unit::TestCase
  include TestExtensions
end
