Given /^Chubbies is running$/ do
  if Chubbies.running?
    puts "Chubbies is already running.  Killing it."
    Chubbies.kill
  end
  Chubbies.run
  at_exit do
    Chubbies.kill
  end
end

Given /^Chubbies is registered on my pod$/ do
  OAuth2::Provider.client_class.create! :name => 'Chubbies',
    :oauth_identifier => 'abcdefgh12345678',
    :oauth_secret => 'secret'
end

And /^I should see my "([^"]+)"/ do |code|
  page.should have_content(@me.person.instance_eval(code).to_s)
end

When /^I try to authorize Chubbies$/ do
  # We need to reset the tokens saved in Chubbies,
  # as we are clearing the Diaspora DB every scenario
  Then 'I visit "/reset" on Chubbies'
  Then 'I visit "/" on Chubbies'
  ###
  And 'I follow "Log in with Diaspora"'
  Then 'I should be on the new user session page'
  And "I fill in \"Username\" with \"#{@me.username}\""
  And "I fill in \"Password\" with \"#{@me.password}\""
  And 'I press "Sign in"'
  Then 'I should be on the oauth authorize page'
end

When /^I visit "([^"]+)" on Chubbies$/ do |path|
  former_host = Capybara.app_host
  Capybara.app_host = "localhost:#{Chubbies::PORT}"
  visit(path)
  Capybara.app_host = former_host
end

class Chubbies
  PORT = 9292

  def self.run
    @pid = fork do
      Process.exec "cd #{Rails.root}/spec/support/chubbies/ && DIASPORA_PORT=9887 bundle exec rackup -p #{PORT} 2> /dev/null"
    end
    while(!running?) do
      sleep(1)
    end
  end

  def self.kill
    `kill -9 #{get_pid}`
  end

  def self.running?
    begin
      RestClient.get("localhost:#{PORT}")
      true
    rescue Errno::ECONNREFUSED
      false
    end
  end

  def self.get_pid
    @pid ||= lambda {
      processes = `ps -ax -o pid,command | grep "rackup -p #{PORT}"`.split("\n")
      processes = processes.select{|p| !p.include?("grep") }
      processes.first.split(" ").first
    }.call
  end
end
