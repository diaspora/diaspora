class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @posts = Post.all
    
    @bookmarks = Bookmark.all
    @status_messages = StatusMessage.all
    @blogs = Blog.all
    #@status_messages = @posts.select{ |x| x._type == "StatusMessage"}
    #@blogs = @posts.select{ |x| x._type == "Blog"}
    #@bookmarks = @posts.select{ |x| x._type == "Bookmarks"}
  end
end
