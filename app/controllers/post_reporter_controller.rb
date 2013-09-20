require 'pp'
require 'logger'
class PostReporterController < ApplicationController
  before_filter :authenticate_user!

  attr_accessor :id

  def index
    redirect_unless_admin
    logger.debug("index")
    @post_reporter = PostReporter.where(reviewed: false).all
  end

  def update
    redirect_unless_admin
    @id = params[:id]
    logger.debug("update")
    mark_as_reviewed if PostReporter.exists?(post_id: self.id)
    redirect_to :action => 'index'
  end

  def destroy
    redirect_unless_admin
    @id = params[:id]
    logger.debug("destroy")
    if Post.exists?(self.id)
      delete_post
      mark_as_reviewed
    end
    redirect_to :action => 'index'
  end

  def create
    @id = params[:post_id]
    logger.debug("create")
    username = current_user.username
    if !PostReporter.where(post_id: self.id).exists?(user_id: username)
      post = PostReporter.new(
        :post_id => self.id,
        :user_id => username,
        :text => params[:text])
      result = post.save
      status(( 200 if result ) || ( 500 if !result ))
    else
      status(409)
    end
  end

  def delete_post
    post = Post.find(self.id)
    logger.debug("deleted")
    post.destroy
  end

  def mark_as_reviewed
    posts = PostReporter.where(post_id: self.id)
    posts.each do |post|
      logger.debug("reviewed")
      post.update_attributes(reviewed: true)
    end
  end

  private
    def status(code)
      render :nothing => true, :status => code
    end
end
