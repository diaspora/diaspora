#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/em-webfinger')

class RequestsController < ApplicationController
  before_filter :authenticate_user!
  include RequestsHelper

  respond_to :html

  def destroy
    if params[:accept]
      if params[:aspect_id]
        @friend = current_user.accept_and_respond( params[:id], params[:aspect_id])
        flash[:notice] = I18n.t 'requests.destroy.success'
        respond_with :location => current_user.aspect_by_id(params[:aspect_id])
      else
        flash[:error] = I18n.t 'requests.destroy.error'
        respond_with :location => requests_url
      end
    else
      current_user.ignore_friend_request params[:id]
      flash[:notice] = I18n.t 'requests.destroy.ignore'
      respond_with :location => requests_url
    end
  end

  def new
    @request = Request.new
  end

 def create
    aspect = current_user.aspect_by_id(params[:aspect_id])
    account = params[:destination_handle].strip  
    begin 
      finger = EMWebfinger.new(account)
    
      finger.on_person{ |person|
      
      if person.class == Person
        rel_hash = {:friend => person}

        Rails.logger.debug("Sending request: #{rel_hash}")

        begin
          @request = current_user.send_friend_request_to(rel_hash[:friend], aspect)
        rescue Exception => e
          Rails.logger.debug("error: #{e.message}")
          flash[:error] = e.message
        end
      else
        #socket to tell people this failed?
      end
      }

    rescue Exception => e 
      flash[:error] = e.message
    end
    
    if params[:getting_started]
      redirect_to getting_started_path(:step=>params[:getting_started])
    else
      flash[:notice] = I18n.t('requests.create.tried', :account => account) unless flash[:error]
      respond_with :location => aspects_manage_path 
      return
    end    
  end
end
