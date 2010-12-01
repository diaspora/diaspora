#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + "/../../lib"
require 'rubygems'
require_gem 'camping', '>=1.4'
require 'camping/session'
  
Camping.goes :Blog

module Blog
    include Camping::Session
end

module Blog::Models
    def self.schema(&block)
        @@schema = block if block_given?
        @@schema
    end
  
    class Post < Base; belongs_to :user; end
    class Comment < Base; belongs_to :user; end
    class User < Base; end
end

Blog::Models.schema do
    create_table :blog_posts, :force => true do |t|
      t.column :id,       :integer, :null => false
      t.column :user_id,  :integer, :null => false
      t.column :title,    :string,  :limit => 255
      t.column :body,     :text
    end
    create_table :blog_users, :force => true do |t|
      t.column :id,       :integer, :null => false
      t.column :username, :string
      t.column :password, :string
    end
    create_table :blog_comments, :force => true do |t|
      t.column :id,       :integer, :null => false
      t.column :post_id,  :integer, :null => false
      t.column :username, :string
      t.column :body,     :text
    end
    execute "INSERT INTO blog_users (username, password) VALUES ('admin', 'camping')"
end

module Blog::Controllers
    class Index < R '/'
        def get
            @posts = Post.find :all
            render :index
        end
    end
     
    class Add
        def get
            unless @state.user_id.blank?
                @user = User.find @state.user_id
                @post = Post.new
            end
            render :add
        end
        def post
            post = Post.create :title => input.post_title, :body => input.post_body,
                               :user_id => @state.user_id
            redirect View, post
        end
    end

    class Info < R '/info/(\d+)', '/info/(\w+)/(\d+)', '/info', '/info/(\d+)/(\d+)/(\d+)/([\w-]+)'
        def get(*args)
            div do
                code args.inspect; br; br
                code ENV.inspect; br
                code "Link: #{R(Info, 1, 2)}"
            end
        end
    end

    class View < R '/view/(\d+)'
        def get post_id 
            @post = Post.find post_id
            @comments = Models::Comment.find :all, :conditions => ['post_id = ?', post_id]
            render :view
        end
    end
     
    class Edit < R '/edit/(\d+)', '/edit'
        def get post_id 
            unless @state.user_id.blank?
                @user = User.find @state.user_id
            end
            @post = Post.find post_id
            render :edit
        end
     
        def post
            @post = Post.find input.post_id
            @post.update_attributes :title => input.post_title, :body => input.post_body
            redirect View, @post
        end
    end
     
    class Comment
        def post
            Models::Comment.create(:username => input.post_username,
                       :body => input.post_body, :post_id => input.post_id)
            redirect View, input.post_id
        end
    end
     
    class Login
        def post
            @user = User.find :first, :conditions => ['username = ? AND password = ?', input.username, input.password]
     
            if @user
                @login = 'login success !'
                @state.user_id = @user.id
            else
                @login = 'wrong user name or password'
            end
            render :login
        end
    end
     
    class Logout
        def get
            @state.user_id = nil
            render :logout
        end
    end
     
    class Style < R '/styles.css'
        def get
            @headers["Content-Type"] = "text/css; charset=utf-8"
            @body = %{
                body {
                    font-family: Utopia, Georga, serif;
                }
                h1.header {
                    background-color: #fef;
                    margin: 0; padding: 10px;
                }
                div.content {
                    padding: 10px;
                }
            }
        end
    end
end

module Blog::Views

    def layout
      html do
        head do
          title 'blog'
          link :rel => 'stylesheet', :type => 'text/css', 
               :href => '/styles.css', :media => 'screen'
        end
        body do
          h1.header { a 'blog', :href => R(Index) }
          div.content do
            self << yield
          end
        end
      end
    end

    def index
      if @posts.empty?
        p 'No posts found.'
        p { a 'Add', :href => R(Add) }
      else
        for post in @posts
          _post(post)
        end
      end
    end

    def login
      p { b @login }
      p { a 'Continue', :href => R(Add) }
    end

    def logout
      p "You have been logged out."
      p { a 'Continue', :href => R(Index) }
    end

    def add
      if @user
        _form(post, :action => R(Add))
      else
        _login
      end
    end

    def edit
      if @user
        _form(post, :action => R(Edit))
      else
        _login
      end
    end

    def view
        _post(post)

        p "Comment for this post:"
        for c in @comments
          h1 c.username
          p c.body
        end

        form :action => R(Comment), :method => 'post' do
          label 'Name', :for => 'post_username'; br
          input :name => 'post_username', :type => 'text'; br
          label 'Comment', :for => 'post_body'; br
          textarea :name => 'post_body' do; end; br
          input :type => 'hidden', :name => 'post_id', :value => post.id
          input :type => 'submit'
        end
    end

    # partials
    def _login
      form :action => R(Login), :method => 'post' do
        label 'Username', :for => 'username'; br
        input :name => 'username', :type => 'text'; br

        label 'Password', :for => 'password'; br
        input :name => 'password', :type => 'text'; br

        input :type => 'submit', :name => 'login', :value => 'Login'
      end
    end

    def _post(post)
      h1 post.title
      p post.body
      p do
        a "Edit", :href => R(Edit, post)
        a "View", :href => R(View, post)
      end
    end

    def _form(post, opts)
      p do
        text "You are logged in as #{@user.username} | "
        a 'Logout', :href => R(Logout)
      end
      form({:method => 'post'}.merge(opts)) do
        label 'Title', :for => 'post_title'; br
        input :name => 'post_title', :type => 'text', 
              :value => post.title; br

        label 'Body', :for => 'post_body'; br
        textarea post.body, :name => 'post_body'; br

        input :type => 'hidden', :name => 'post_id', :value => post.id
        input :type => 'submit'
      end
    end
end
 
def Blog.create
    Camping::Models::Session.create_schema
    unless Blog::Models::Post.table_exists?
        ActiveRecord::Schema.define(&Blog::Models.schema)
    end
end

if __FILE__ == $0
  require 'mongrel/camping'

  Blog::Models::Base.establish_connection :adapter => 'sqlite3', :database => 'blog.db'
  Blog::Models::Base.logger = Logger.new('camping.log')
  Blog::Models::Base.threaded_connections=false
  Blog.create
  
  # Use the Configurator as an example rather than Mongrel::Camping.start
  config = Mongrel::Configurator.new :host => "0.0.0.0" do
    listener :port => 3002 do
      uri "/blog", :handler => Mongrel::Camping::CampingHandler.new(Blog)
      uri "/favicon", :handler => Mongrel::Error404Handler.new("")
      trap("INT") { stop }
      run
    end
  end

  puts "** Blog example is running at http://localhost:3002/blog"
  puts "** Default username is `admin', password is `camping'"
  config.join
end
