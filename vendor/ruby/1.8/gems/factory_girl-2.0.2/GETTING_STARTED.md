Getting Started
===============

Update Your Gemfile
-------------------

If you're using Rails, you'll need to upgrade `factory_girl_rails` to the latest RC:

    gem "factory_girl_rails", "~> 1.1"

If you're *not* using Rails, you'll just have to change the required version of `factory_girl`:

    gem "factory_girl", "~> 2.0.0"

Once your Gemfile is updated, you'll want to update your bundle.

Defining factories
------------------

Each factory has a name and a set of attributes. The name is used to guess the class of the object by default, but it's possible to explicitly specify it:

    # This will guess the User class
    FactoryGirl.define do
      factory :user do
        first_name 'John'
        last_name  'Doe'
        admin false
      end

      # This will use the User class (Admin would have been guessed)
      factory :admin, :class => User do
        first_name 'Admin'
        last_name  'User'
        admin true
      end

      # The same, but using a string instead of class constant
      factory :admin, :class => 'user' do
        first_name 'Admin'
        last_name  'User'
        admin true
      end
    end

It is highly recommended that you have one factory for each class that provides the simplest set of attributes necessary to create an instance of that class. If you're creating ActiveRecord objects, that means that you should only provide attributes that are required through validations and that do not have defaults. Other factories can be created through inheritance to cover common scenarios for each class.

Attempting to define multiple factories with the same name will raise an error.

Factories can be defined anywhere, but will be automatically loaded if they
are defined in files at the following locations:

    test/factories.rb
    spec/factories.rb
    test/factories/*.rb
    spec/factories/*.rb

Using factories
---------------

factory_girl supports several different build strategies: build, create, attributes_for and stub:

    # Returns a User instance that's not saved
    user = FactoryGirl.build(:user)

    # Returns a saved User instance
    user = FactoryGirl.create(:user)

    # Returns a hash of attributes that can be used to build a User instance
    attrs = FactoryGirl.attributes_for(:user)

    # Returns an object with all defined attributes stubbed out
    stub = FactoryGirl.stub(:user)

No matter which strategy is used, it's possible to override the defined attributes by passing a hash:

    # Build a User instance and override the first_name property
    user = FactoryGirl.build(:user, :first_name => 'Joe')
    user.first_name
    # => "Joe"

If repeating "FactoryGirl" is too verbose for you, you can mix the syntax methods in:

    # rspec
    RSpec.configure do |config|
      config.include Factory::Syntax::Methods
    end

    # Test::Unit
    class Test::Unit::TestCase
      include Factory::Syntax::Methods
    end

This would allow you to write:

    describe User, "#full_name" do
      subject { create(:user, :first_name => "John", :last_name => "Doe") }

      its(:full_name) { should == "John Doe" }
    end

Lazy Attributes
---------------

Most factory attributes can be added using static values that are evaluated when the factory is defined, but some attributes (such as associations and other attributes that must be dynamically generated) will need values assigned each time an instance is generated. These "lazy" attributes can be added by passing a block instead of a parameter:

    factory :user do
      # ...
      activation_code { User.generate_activation_code }
      date_of_birth   { 21.years.ago }
    end

Aliases
-------

Aliases allow you to use named associations more easily.

    factory :user, :aliases => [:author, :commenter] do
      first_name    "John"
      last_name     "Doe"
      date_of_birth { 18.years.ago }
    end

    factory :post do
      author
      # instead of
      # association :author, :factory => :user
      title "How to read a book effectively"
      body  "There are five steps involved."
    end

    factory :comment do
      commenter
      # instead of
      # association :commenter, :factory => :user
      body "Great article!"
    end

Dependent Attributes
--------------------

Attributes can be based on the values of other attributes using the proxy that is yielded to lazy attribute blocks:

    factory :user do
      first_name 'Joe'
      last_name  'Blow'
      email { "#{first_name}.#{last_name}@example.com".downcase }
    end

    FactoryGirl.create(:user, :last_name => 'Doe').email
    # => "joe.doe@example.com"

Associations
------------

It's possbile to set up associations within factories. If the factory name is the same as the association name, the factory name can be left out.

    factory :post do
      # ...
      author
    end

You can also specify a different factory or override attributes:

    factory :post do
      # ...
      association :author, :factory => :user, :last_name => 'Writely'
    end

The behavior of the association method varies depending on the build strategy used for the parent object.

    # Builds and saves a User and a Post
    post = FactoryGirl.create(:post)
    post.new_record?       # => false
    post.author.new_record # => false

    # Builds and saves a User, and then builds but does not save a Post
    post = FactoryGirl.build(:post)
    post.new_record?       # => true
    post.author.new_record # => false

Inheritance
-----------

You can easily create multiple factories for the same class without repeating common attributes by nesting factories:

    factory :post do
      title 'A title'

      factory :approved_post do
        approved true
      end
    end

    approved_post = FactoryGirl.create(:approved_post)
    approved_post.title # => 'A title'
    approved_post.approved # => true

You can also assign the parent explicitly:

    factory :post do
      title 'A title'
    end

    factory :approved_post, :parent => :post do
      approved true
    end

As mentioned above, it's good practice to define a basic factory for each class with only the attributes required to create it. Then, create more specific factories that inherit from this basic parent. Factory definitions are still code, so keep them DRY.

Sequences
---------

Unique values in a specific format (for example, e-mail addresses) can be
generated using sequences. Sequences are defined by calling sequence in a
definition block, and values in a sequence are generated by calling
Factory.next:

    # Defines a new sequence
    FactoryGirl.define do
      sequence :email do |n|
        "person#{n}@example.com"
      end
    end

    Factory.next :email
    # => "person1@example.com"

    Factory.next :email
    # => "person2@example.com"

Sequences can be used as attributes:

    factory :user do
      email
    end

Or in lazy attributes:

    factory :invite do
      invitee { Factory.next(:email) }
    end

And it's also possible to define an in-line sequence that is only used in
a particular factory:

    factory :user do
      sequence(:email) {|n| "person#{n}@example.com" }
    end

You can also override the initial value:

    factory :user do
      sequence(:email, 1000) {|n| "person#{n}@example.com" }
    end

Without a block, the value will increment itself, starting at its initial value:

    factory :post do
      sequence(:position)
    end

Callbacks
---------

Factory_girl makes available three callbacks for injecting some code:

* after_build  - called after a factory is built   (via FactoryGirl.build)
* after_create - called after a factory is saved   (via FactoryGirl.create)
* after_stub   - called after a factory is stubbed (via FactoryGirl.stub)

Examples:

    # Define a factory that calls the generate_hashed_password method after it is built
    factory :user do
      after_build { |user| generate_hashed_password(user) }
    end

Note that you'll have an instance of the user in the block. This can be useful.

You can also define multiple types of callbacks on the same factory:

    factory :user do
      after_build  { |user| do_something_to(user) }
      after_create { |user| do_something_else_to(user) }
    end

Factories can also define any number of the same kind of callback.  These callbacks will be executed in the order they are specified:

    factory :user do
      after_create { this_runs_first }
      after_create { then_this }
    end

Calling FactoryGirl.create will invoke both after_build and after_create callbacks.

Also, like standard attributes, child factories will inherit (and can also define) callbacks from their parent factory.

Building or Creating Multiple Records
-------------------------------------

Sometimes, you'll want to create or build multiple instances of a factory at once.

    built_users   = FactoryGirl.build_list(:user, 25)
    created_users = FactoryGirl.create_list(:user, 25)

These methods will build or create a specific amount of factories and return them as an array.
To set the attributes for each of the factories, you can pass in a hash as you normally would.

    twenty_year_olds = FactoryGirl.build_list(:user, 25, :date_of_birth => 20.years.ago)

Cucumber Integration
--------------------

factory_girl ships with step definitions that make calling factories from Cucumber easier. To use them:

    require 'factory_girl/step_definitions' 

Alternate Syntaxes
------------------

Users' tastes for syntax vary dramatically, but most users are looking for a common feature set. Because of this factory_girl supports "syntax layers" which provide alternate interfaces. See Factory::Syntax for information about the various layers available. For example, the Machinist-style syntax is popular:

    require 'factory_girl/syntax/blueprint'
    require 'factory_girl/syntax/make'
    require 'factory_girl/syntax/sham'

    Sham.email {|n| "#{n}@example.com" }

    User.blueprint do
      name  { 'Billy Bob' }
      email { Sham.email  }
    end

    User.make(:name => 'Johnny')
