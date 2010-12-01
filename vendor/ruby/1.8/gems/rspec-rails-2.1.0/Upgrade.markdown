# Upgrade to rspec-rails-2

## Webrat and Capybara

Earlier 2.0.0.beta versions depended on Webrat. As of
rspec-rails-2.0.0.beta.20, this dependency and offers you a choice of using
webrat or capybara. Just add the library of your choice to your Gemfile.

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

## View specs

Rails changed the way it renders partials, so to set an expectation that a
partial gets rendered:

    render
    view.should render_template(:partial => "widget/_row")

## as_new_record

Earlier versions of the view generators generated stub_model with `:new_record?
=> true`. As of rspec-rails-2.0.0.rc, that is no longer recognized, so you need
to change this:
  
    stub_model(Widget, :new_record? => true)

to this:

    stub_model(Widget).as_new_record

Generators in 2.0.0 final release will do the latter.

