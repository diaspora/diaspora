#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PublicsController < ApplicationController
  include Diaspora::Parser

  skip_before_action :set_header_data
  skip_before_action :set_grammatical_gender
  before_action :check_for_xml, :only => [:receive, :receive_public]
  before_action :authenticate_user!, :only => [:index]

  respond_to :html
  respond_to :xml, :only => :post

  layout false

  def hub
    render :text => params['hub.challenge'], :status => 202, :layout => false
  end

  def receive_public
    logger.info "received a public message"
    Workers::ReceiveUnencryptedSalmon.perform_async(CGI::unescape(params[:xml]))
    render :nothing => true, :status => :ok
  end

  def receive
    person = Person.find_by_guid(params[:guid])

    if person.nil? || person.owner_id.nil?
      logger.error "Received post for nonexistent person #{params[:guid]}"
      render :nothing => true, :status => 404
      return
    end

    @user = person.owner

    logger.info "received a private message for user: #{@user.id}"
    Workers::ReceiveEncryptedSalmon.perform_async(@user.id, CGI::unescape(params[:xml]))

    render :nothing => true, :status => 202
  end

  private

  def check_for_xml
    if params[:xml].nil?
      render :nothing => true, :status => 422
      return
    end
  end
end
