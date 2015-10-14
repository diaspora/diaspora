include Warden::Test::Helpers

def login(user)
  login_as user, scope: :user
end
