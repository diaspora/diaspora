Given /^Chubbies is running$/ do
  Chubbies.run unless Chubbies.running?
end

Given /^Chubbies has been killed$/ do
  Chubbies.kill
end

Given /^Chubbies is registered on my pod$/ do
  packaged_manifest = JSON.parse(RestClient.get("localhost:#{Chubbies::PORT}/manifest.json").body)
  public_key = OpenSSL::PKey::RSA.new(packaged_manifest['public_key'])
  manifest = JWT.decode(packaged_manifest['jwt'], public_key)

  client = OAuth2::Provider.client_class.create_or_reset_from_manifest!(manifest, public_key)
  params = {:client_id => client.oauth_identifier,
            :client_secret => client.oauth_secret,
            :host => "localhost:9887"}
  RestClient.post("localhost:#{Chubbies::PORT}/register", params)
end

And /^I should see my "([^"]+)"/ do |code|
  page.should have_content(@me.person.instance_eval(code).to_s)
end

And /^there is only one Chubbies$/ do
  OAuth2::Provider.client_class.where(:name => "Chubbies").count.should == 1
end

And /^I remove all traces of Chubbies on the pod$/ do
  OAuth2::Provider.client_class.destroy_all
end

When /^I try to authorize Chubbies$/ do
  # We need to reset the tokens saved in Chubbies,
  # as we are clearing the Diaspora DB every scenario
  Then 'I visit "/new" on Chubbies'
  ###
  And "I fill in my Diaspora ID to connect"
  And 'I press "Connect to Diaspora"'
  Then 'I should be on the new user session page'
  And "I fill in \"Username\" with \"#{@me.username}\""
  And "I fill in \"Password\" with \"#{@me.password}\""
  And 'I press "Sign in"'
  Then 'I should be on the oauth authorize page'
  Then 'I should see "Chubbies"'
  And 'I should see "The best way to chub."'
end

And /^I fill in my Diaspora ID to connect$/ do
  And "I fill in \"Diaspora Handle\" with \"#{@me.diaspora_handle}\""
end

And /^I should have (\d) user on Chubbies$/ do |num|
  When "I visit \"/user_count\" on Chubbies"
  Then "I should see \"#{num}\""
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
      Process.exec "cd #{Rails.root}/spec/chubbies/ && bundle exec #{run_command} #{nullify}"
    end

    at_exit do
      Chubbies.kill
    end

    while(!running?) do
      sleep(1)
    end
  end

  def self.nullify
   # "2> /dev/null > /dev/null"
  end

  def self.kill
    pid = self.get_pid
    `kill -9 #{pid}` if pid.present?
  end

  def self.running?
    begin
      begin
      RestClient.get("localhost:#{PORT}/running")
      rescue RestClient::ResourceNotFound
      end
      true
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET
      false
    end
  end

  def self.run_command
    "rackup -p #{PORT}"
  end

  def self.get_pid
    processes = `ps ax -o pid,command | grep "#{run_command}"`.split("\n")
    processes = processes.select{|p| !p.include?("grep") }
    if processes.any?
      processes.first.split(" ").first
    else
      nil
    end
  end
end
