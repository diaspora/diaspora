#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SocketsController < ApplicationController
  include ApplicationHelper
  include SocketsHelper
  include Rails.application.routes.url_helpers
  helper_method :all_aspects
  helper_method :current_user
  helper_method 'all_comments?'

  def incoming(msg)
    Rails.logger.info("Socket received connection to: #{msg}")
  end

  def outgoing(user_or_id, object, opts={})
    #this should be the actual params of the controller
    @params = {:user_or_id => user_or_id, :object => object}.merge(opts)
    return unless Diaspora::WebSocket.is_connected?(user_id)
    @_request = SocketRequest.new({})
    Diaspora::WebSocket.queue_to_user(user_id, action_hash(user, object, opts))
  end

  def user_id
    if @params[:user_or_id].instance_of?(Fixnum)
      @user_id ||= @params[:user_or_id]
    else
      @user_id ||= @params[:user_or_id].id
    end
  end

  def user
   @user ||= ((@params[:user_or_id].instance_of? User )? @params[:user_or_id] : User.find(user_id))
  end

  def current_user
    user
  end

  def url_options
    {:host => "#{AppConfig[:pod_uri].host}:#{AppConfig[:pod_uri].port}"}
  end

  def all_aspects
    @all_aspects ||= user.aspects
  end

  # Override of CommentsHelper#all_comments? .
  def all_comments?
    false
  end

  class SocketRequest < ActionDispatch::Request
    def format
      'socket'
    end
  end
end
