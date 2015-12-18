#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PublicsController < ApplicationController
  include Diaspora::Parser

  skip_before_action :set_header_data
  skip_before_action :set_grammatical_gender
  before_action :authenticate_user!, :only => [:index]

  respond_to :html
  respond_to :xml, :only => :post

  layout false

  def hub
    render :text => params['hub.challenge'], :status => 202, :layout => false
  end
end
