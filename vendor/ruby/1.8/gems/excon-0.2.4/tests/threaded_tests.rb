require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

with_rackup do
  Shindo.tests do
    test('threaded requests') do
      connection = Excon.new('http://127.0.0.1:9292')

      long_thread = Thread.new {
        response = connection.request(:method => 'GET', :path => '/id/1/wait/2')
        Thread.current[:success] = response.body == '1'
      }

      short_thread = Thread.new {
        response = connection.request(:method => 'GET', :path => '/id/2/wait/1')
        Thread.current[:success] = response.body == '2'
      }

      long_thread.join
      short_thread.join

      long_thread[:success] && short_thread[:success]
    end
  end
end
