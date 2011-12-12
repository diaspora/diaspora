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

  client = OAuth2::Provider.client_class.find_or_create_from_manifest!(manifest, public_key)
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
  step 'I visit "/new" on Chubbies'
  ###
  step "I fill in my Diaspora ID to connect"
  step 'I press "Connect to Diaspora"'
  step 'I should be on the new user session page'
  step "I fill in \"Username\" with \"#{@me.username}\""
  step "I fill in \"Password\" with \"#{@me.password}\""
  step 'I press "Sign in"'
  step 'I should be on the oauth authorize page'
  step 'I should see "Chubbies"'
  step 'I should see "The best way to chub."'
end

And /^I fill in my Diaspora ID to connect$/ do
  step "I fill in \"Diaspora ID\" with \"#{@me.diaspora_handle}\""
end

And /^I should have (\d) user on Chubbies$/ do |num|
  step "I visit \"/user_count\" on Chubbies"
  step "I should see \"#{num}\""
end

When /^I visit "([^"]+)" on Chubbies$/ do |path|
  Capybara.app_host = "http://localhost:#{Chubbies::PORT}"
  visit(path)
end

When /^I change the app_host to Diaspora$/ do
  Capybara.app_host = "http://localhost:9887"
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
    "2> /dev/null > /dev/null"
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

