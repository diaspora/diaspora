rspec-rails offers a number of custom matchers, most of which are
rspec-compatible wrappers for Rails' assertions.

### redirects

    # delegates to assert_redirected_to
    response.should redirect_to(path)

### templates

    # delegates to assert_template
    response.should render_template(template_name)

### assigned objects

    # passes if assigns(:widget) is an instance of Widget
    # and it is not persisted
    assigns(:widget).should be_a_new(Widget)
