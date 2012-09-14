module UserCukeHelpers

  # creates a new user object from the factory with some default attributes
  # and the given override attributes, adds the standard aspects to it
  # and returns it
  def create_user(overrides={})
    default_attrs = {
        :password => 'password',
        :password_confirmation => 'password',
        :getting_started => false
    }

    user = FactoryGirl.create(:user, default_attrs.merge(overrides))
    add_standard_aspects(user)
    user
  end

  # create the default testing aspects for a given user
  def add_standard_aspects(user)
    user.aspects.create(:name => "Besties")
    user.aspects.create(:name => "Unicorns")
  end

  # fill out the fields on the sign_in page and press submit
  def login_as(user, pass)
    fill_in 'user_username', :with=>user
    fill_in 'user_password', :with=>pass
    click_button :submit
  end

  # create a new @me user, if not present, and log in using the
  # integration_sessions controller (automatic)
  def automatic_login
    @me ||= FactoryGirl.create(:user_with_aspect, :getting_started => false)
    page.driver.visit(new_integration_sessions_path(:user_id => @me.id))
    click_button "Login"
  end

  # use the @me user to perform a manual login via the sign_in page
  def manual_login
    visit login_page
    login_as @me.username, @me.password
  end

  # checks the page content to see, if the login was successful
  def confirm_login
    wait_until { page.has_content?("#{@me.first_name} #{@me.last_name}") }
  end

  # delete all cookies, destroying the current session
  def logout
    $browser.delete_cookie('_session', 'path=/') if $browser
    $browser.delete_all_visible_cookies if $browser
  end

  # go to user menu, expand it, and click logout
  def manual_logout
    find("#user_menu li:first-child a").click
    find("#user_menu li:last-child a").click
  end

  # fill change password section on the user edit page 
  def fill_change_password_section(cur_pass, new_pass, confirm_pass)
    fill_in 'user_current_password', :with => cur_pass
    fill_in 'user_password', :with => new_pass
    fill_in 'user_password_confirmation', :with => confirm_pass
  end

  # fill forgot password form to get reset password link 
  def fill_forgot_password_form(email)
    fill_in 'user_email', :with => email
  end

  # submit forgot password form to get reset password link
  def submit_forgot_password_form
    find("#new_user input.button").click
  end

  # fill the reset password form
  def fill_reset_password_form(new_pass, confirm_pass)
    fill_in 'user_password', :with => new_pass
    fill_in 'user_password_confirmation', :with => confirm_pass
  end

  # submit reset password form
  def submit_reset_password_form
    find(".button").click
  end

end

World(UserCukeHelpers)
