require "action_controller/log_subscriber"

module ActionController
  # Action Controllers are the core of a web request in \Rails. They are made up of one or more actions that are executed
  # on request and then either render a template or redirect to another action. An action is defined as a public method
  # on the controller, which will automatically be made accessible to the web-server through \Rails Routes.
  #
  # By default, only the ApplicationController in a \Rails application inherits from <tt>ActionController::Base</tt>. All other
  # controllers in turn inherit from ApplicationController. This gives you one class to configure things such as
  # request forgery protection and filtering of sensitive request parameters.
  #
  # A sample controller could look like this:
  #
  #   class PostsController < ApplicationController
  #     def index
  #       @posts = Post.all
  #     end
  #
  #     def create
  #       @post = Post.create params[:post]
  #       redirect_to posts_path
  #     end
  #   end
  #
  # Actions, by default, render a template in the <tt>app/views</tt> directory corresponding to the name of the controller and action
  # after executing code in the action. For example, the +index+ action of the PostsController would render the
  # template <tt>app/views/posts/index.erb</tt> by default after populating the <tt>@posts</tt> instance variable.
  #
  # Unlike index, the create action will not render a template. After performing its main purpose (creating a
  # new post), it initiates a redirect instead. This redirect works by returning an external
  # "302 Moved" HTTP response that takes the user to the index action.
  #
  # These two methods represent the two basic action archetypes used in Action Controllers. Get-and-show and do-and-redirect.
  # Most actions are variations of these themes.
  #
  # == Requests
  #
  # For every request, the router determines the value of the +controller+ and +action+ keys. These determine which controller
  # and action are called. The remaining request parameters, the session (if one is available), and the full request with
  # all the HTTP headers are made available to the action through accessor methods. Then the action is performed.
  #
  # The full request object is available via the request accessor and is primarily used to query for HTTP headers:
  #
  #   def server_ip
  #     location = request.env["SERVER_ADDR"]
  #     render :text => "This server hosted at #{location}"
  #   end
  #
  # == Parameters
  #
  # All request parameters, whether they come from a GET or POST request, or from the URL, are available through the params method
  # which returns a hash. For example, an action that was performed through <tt>/posts?category=All&limit=5</tt> will include
  # <tt>{ "category" => "All", "limit" => 5 }</tt> in params.
  #
  # It's also possible to construct multi-dimensional parameter hashes by specifying keys using brackets, such as:
  #
  #   <input type="text" name="post[name]" value="david">
  #   <input type="text" name="post[address]" value="hyacintvej">
  #
  # A request stemming from a form holding these inputs will include <tt>{ "post" => { "name" => "david", "address" => "hyacintvej" } }</tt>.
  # If the address input had been named "post[address][street]", the params would have included
  # <tt>{ "post" => { "address" => { "street" => "hyacintvej" } } }</tt>. There's no limit to the depth of the nesting.
  #
  # == Sessions
  #
  # Sessions allows you to store objects in between requests. This is useful for objects that are not yet ready to be persisted,
  # such as a Signup object constructed in a multi-paged process, or objects that don't change much and are needed all the time, such
  # as a User object for a system that requires login. The session should not be used, however, as a cache for objects where it's likely
  # they could be changed unknowingly. It's usually too much work to keep it all synchronized -- something databases already excel at.
  #
  # You can place objects in the session by using the <tt>session</tt> method, which accesses a hash:
  #
  #   session[:person] = Person.authenticate(user_name, password)
  #
  # And retrieved again through the same hash:
  #
  #   Hello #{session[:person]}
  #
  # For removing objects from the session, you can either assign a single key to +nil+:
  #
  #   # removes :person from session
  #   session[:person] = nil
  #
  # or you can remove the entire session with +reset_session+.
  #
  # Sessions are stored by default in a browser cookie that's cryptographically signed, but unencrypted.
  # This prevents the user from tampering with the session but also allows him to see its contents.
  #
  # Do not put secret information in cookie-based sessions!
  #
  # Other options for session storage:
  #
  # * ActiveRecord::SessionStore - Sessions are stored in your database, which works better than PStore with multiple app servers and,
  #   unlike CookieStore, hides your session contents from the user. To use ActiveRecord::SessionStore, set
  #
  #     config.action_controller.session_store = :active_record_store
  #
  #   in your <tt>config/environment.rb</tt> and run <tt>rake db:sessions:create</tt>.
  #
  # == Responses
  #
  # Each action results in a response, which holds the headers and document to be sent to the user's browser. The actual response
  # object is generated automatically through the use of renders and redirects and requires no user intervention.
  #
  # == Renders
  #
  # Action Controller sends content to the user by using one of five rendering methods. The most versatile and common is the rendering
  # of a template. Included in the Action Pack is the Action View, which enables rendering of ERb templates. It's automatically configured.
  # The controller passes objects to the view by assigning instance variables:
  #
  #   def show
  #     @post = Post.find(params[:id])
  #   end
  #
  # Which are then automatically available to the view:
  #
  #   Title: <%= @post.title %>
  #
  # You don't have to rely on the automated rendering. Especially actions that could result in the rendering of different templates will use
  # the manual rendering methods:
  #
  #   def search
  #     @results = Search.find(params[:query])
  #     case @results
  #       when 0 then render :action => "no_results"
  #       when 1 then render :action => "show"
  #       when 2..10 then render :action => "show_many"
  #     end
  #   end
  #
  # Read more about writing ERb and Builder templates in ActionView::Base.
  #
  # == Redirects
  #
  # Redirects are used to move from one action to another. For example, after a <tt>create</tt> action, which stores a blog entry to a database,
  # we might like to show the user the new entry. Because we're following good DRY principles (Don't Repeat Yourself), we're going to reuse (and redirect to)
  # a <tt>show</tt> action that we'll assume has already been created. The code might look like this:
  #
  #   def create
  #     @entry = Entry.new(params[:entry])
  #     if @entry.save
  #       # The entry was saved correctly, redirect to show
  #       redirect_to :action => 'show', :id => @entry.id
  #     else
  #       # things didn't go so well, do something else
  #     end
  #   end
  #
  # In this case, after saving our new entry to the database, the user is redirected to the <tt>show</tt> method which is then executed.
  #
  # == Calling multiple redirects or renders
  #
  # An action may contain only a single render or a single redirect. Attempting to try to do either again will result in a DoubleRenderError:
  #
  #   def do_something
  #     redirect_to :action => "elsewhere"
  #     render :action => "overthere" # raises DoubleRenderError
  #   end
  #
  # If you need to redirect on the condition of something, then be sure to add "and return" to halt execution.
  #
  #   def do_something
  #     redirect_to(:action => "elsewhere") and return if monkeys.nil?
  #     render :action => "overthere" # won't be called if monkeys is nil
  #   end
  #
  class Base < Metal
    abstract!

    def self.without_modules(*modules)
      modules = modules.map do |m|
        m.is_a?(Symbol) ? ActionController.const_get(m) : m
      end

      MODULES - modules
    end

    MODULES = [
      AbstractController::Layouts,
      AbstractController::Translation,
      AbstractController::AssetPaths,

      Helpers,
      HideActions,
      UrlFor,
      Redirecting,
      Rendering,
      Renderers::All,
      ConditionalGet,
      RackDelegation,
      SessionManagement,
      Caching,
      MimeResponds,
      ImplicitRender,

      Cookies,
      Flash,
      RequestForgeryProtection,
      Streaming,
      RecordIdentifier,
      HttpAuthentication::Basic::ControllerMethods,
      HttpAuthentication::Digest::ControllerMethods,
      HttpAuthentication::Token::ControllerMethods,

      # Add instrumentations hooks at the bottom, to ensure they instrument
      # all the methods properly.
      Instrumentation,

      # Before callbacks should also be executed the earliest as possible, so
      # also include them at the bottom.
      AbstractController::Callbacks,

      # The same with rescue, append it at the end to wrap as much as possible.
      Rescue
    ]

    MODULES.each do |mod|
      include mod
    end

    # Rails 2.x compatibility
    include ActionController::Compatibility

    def self.inherited(klass)
      super
      klass.helper :all if klass.superclass == ActionController::Base
    end

    require "action_controller/deprecated/base"
    ActiveSupport.run_load_hooks(:action_controller, self)
  end
end

