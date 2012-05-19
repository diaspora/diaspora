module UserCukeHelpers
  def create_user(overrides={})
    default_attrs = {
        :password => 'password',
        :password_confirmation => 'password',
        :getting_started => false
    }

    user = Factory(:user, default_attrs.merge(overrides))
    add_standard_aspects(user)
    user
  end

  def add_standard_aspects(user)
    user.aspects.create(:name => "Besties")
    user.aspects.create(:name => "Unicorns")
  end

  def login_as(user, pass)
    fill_in 'user_username', :with=>user
    fill_in 'user_password', :with=>pass
    click_button :submit
  end
end

World(UserCukeHelpers)
