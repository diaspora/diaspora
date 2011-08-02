# Upgrading from rspec-rails-1.x to rspec-rails-2.

This is a work in progress. Please submit errata, missing steps, or patches to
the [rspec-rails issue tracker](https://github.com/rspec/rspec-rails/issues).

## Rake tasks

Delete lib/tasks/rspec.rake, if present. Rake tasks now live in the rspec-rails
gem.

## `spec_helper.rb`

There were a few changes to the generated `spec/spec_helper.rb` file. We
recommend the following:

1. set aside a copy of your existing `spec/spec_helper.rb` file.
2. run `rails generate rspec:install`
3. copy any customizations from your old spec_helper to the new one

If you prefer to make the changes manually in the existing spec_helper, here
is what you need to change:

    # rspec-1
    require 'spec/autorun'

    Spec::Runner.configure do |config|
      ...
    end

    # rspec-2
    require 'rspec/rails'

    RSpec.configure do |config|
      ...
    end

## Controller specs

### islation from view templates

By default, controller specs do _not_ render view templates. This keeps
controller specs isolated from the content of views and their requirements.

NOTE that the template must exist, but it will not be rendered.  This is
different from rspec-rails-1.x, in which the template didn't need to exist, but
ActionController makes a number of new decisions in Rails 3 based on the
existence of the template. To keep the RSpec code free of monkey patches, and
to keep the rspec user experience simpler, we decided that this would be a fair
trade-off.

### `response.should render_template`

This needs to move from before the action to after. For example:

    # rspec-rails-1
    controller.should render_template("edit")
    get :edit, :id => "37"

    # rspec-rails-2
    get :edit, :id => "37"
    response.should render_template("edit")

rspec-1 had to monkey patch Rails to get render_template to work before the
action, and this broke a couple of times with Rails releases (requiring urgent
fix releases in RSpec). Part of the philosophy of rspec-rails-2 is to rely on
public APIs in Rails as much as possible. In this case, `render_template`
delegates directly to Rails' `assert_template`, which only works after the
action.

## View specs

### `view.should render_template`

Rails changed the way it renders partials, so to set an expectation that a
partial gets rendered, you need

    render
    view.should render_template(:partial => "widget/_row")

### stub_template

Introduced in rspec-rails-2.2, simulates the presence of view templates on the
file system. This supports isolation from partials rendered by the vew template
that is the subject of a view example:

    stub_template "widgets/_widget.html.erb" => "This Content"

### No more `have_tag` or `have_text`

Before Webrat came along, rspec-rails had its own `have_tag` and `have_text`
matchers that wrapped Rails' `assert_select`. Webrat included replacements for
these methods, as well as new matchers (`have_selector` and `have_xpath`), all
of which rely on Nokogiri to do its work, and are far less brittle than RSpec's
`have_tag`.

Capybara has similar matchers, which will soon be available view specs (they
are already available in controller specs with `render_views`).

Given the brittleness of RSpec's `have_tag` and `have_text` matchers and the
presence of new Webrat and Capybara matchers that do a better job, `have_tag`
and `have_text` were not included in rspec-rails-2.

## Mocks, stubs, doubles

### as_new_record

Earlier versions of the view generators generated stub_model with `:new_record?
=> true`. That is no longer recognized in rspec-rails-2, so you need to change
this:

    stub_model(Widget, :new_record? => true)

to this:

    stub_model(Widget).as_new_record

Generators in 2.0.0 final release will do the latter.
