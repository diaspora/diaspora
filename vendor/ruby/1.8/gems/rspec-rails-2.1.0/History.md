## rspec-rails-2 release history (incomplete)

### 2.1.0 / 2010-11-07

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.1...v2.1.0)

* Enhancements
  * Move errors_on to ActiveModel to support other AM-compliant ORMs

* Bug fixes
  * Check for presence of ActiveRecord instead of checking Rails config
    (gets rspec out of the way of multiple ORMs in the same app)

### 2.0.1 / 2010-10-15

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.0...v2.0.1)

* Enhancements
  * Add option to not generate request spec (--skip-request-specs)

* Bug fixes
  * Updated the mock_[model] method generated in controller specs so it adds
    any stubs submitted each time it is called.
  * Fixed bug where view assigns weren't making it to the view in view specs in Rails-3.0.1.
    (Emanuele Vicentini)

### 2.0.0 / 2010-10-10

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.0.rc...v2.0.0)

* Changes
  * route_to matcher delegates to assert_recognizes instead of assert_routing
  * update generators to use as_new_record instead of :new_record => true

### 2.0.0.rc / 2010-10-05

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.0.beta.22...v2.0.0.rc)

* Enhancements
  * add --webrat-matchers flag to scaffold generator (for view specs)
  * separate ActiveModel and ActiveRecord APIs in mock_model and stub_model
  * ControllerExampleGroup uses controller as the implicit subject by default (Paul Rosania)

### 2.0.0.beta.22 / 2010-09-12

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.0.beta.20...v2.0.0.beta.22)

* Enhancements
  * autotest mapping improvements (Andreas Neuhaus)

* Bug fixes
  * delegate flunk to assertion delegate

### 2.0.0.beta.20 / 2010-08-24

[full changelog](http://github.com/rspec/rspec-rails/compare/v2.0.0.beta.19...v2.0.0.beta.20)

* Enhancements
  * infer controller and action path_params in view specs
  * more cucumber features (Justin Ko)
  * clean up spec helper (Andre Arko)
  * render views in controller specs if controller class is not
    ActionController::Base
  * routing specs can access named routes
  * add assign(name, value) to helper specs (Justin Ko)
  * stub_model supports primary keys other than id (Justin Ko)
  * encapsulate Test::Unit and/or MiniTest assertions in a separate object
  * support choice between Webrat/Capybara (Justin Ko)
    * removed hard dependency on Webrat
  * support specs for 'abstract' subclasses of ActionController::Base (Mike Gehard)
  * be_a_new matcher supports args (Justin Ko)

* Bug fixes
  * support T::U components in mailer and request specs (Brasten Sager)
