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
        @contact = current_user.accept_and_respond( params[:id], params[:aspect_id])
        flash[:notice] = I18n.t 'requests.destroy.success'
        respond_with :location => current_user.aspect_by_id(params[:aspect_id])
      else
        flash[:error] = I18n.t 'requests.destroy.error'
        respond_with :location => requests_url
      end
    else
      current_user.ignore_contact_request params[:id]
      flash[:notice] = I18n.t 'requests.destroy.ignore'
      head :ok
    end
  end

  def new
    @request = Request.new
  end

 def create
   aspect = current_user.aspect_by_id(params[:request][:into])
   account = params[:request][:to].strip  
   person = Person.by_account_identifier(account)
   existing_request = Request.from(person).to(current_user.person).where(:sent => false).first if person
   if existing_request
     current_user.accept_and_respond(existing_request.id, aspect.id)
     redirect_to :back
   else
     @request = Request.instantiate(:to => person,
                                    :from => current_user.person,
                                    :into => aspect)
     if @request.save
       current_user.dispatch_request(@request)
       flash.now[:notice] = I18n.t('requests.create.sent')
       redirect_to :back
     else
       flash.now[:error] = @request.errors.full_messages.join(', ')
       redirect_to :back
     end
   end
  end
end
