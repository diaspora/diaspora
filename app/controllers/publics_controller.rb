#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


class PublicsController < ApplicationController
  require 'lib/diaspora/parser'
  include Diaspora::Parser
  layout false
  
  def hcard
    @person = Person.find_by_id params[:id]
    puts @person
    unless @person.nil? || @person.owner.nil?
      render 'hcard'
    end
  end

  def host_meta
    render 'host_meta', :content_type => 'application/xrd+xml'
  end

  def webfinger
    @person = Person.by_webfinger(params[:q])
    unless @person.nil? || @person.owner.nil?
      render 'webfinger', :content_type => 'application/xrd+xml'
    end
  end
  
  def receive
    render :nothing => true
    return unless params[:xml]
    begin
      @user = Person.first(:id => params[:id]).owner
    rescue NoMethodError => e
      Rails.logger.error("Received post #{params[:xml]} for nonexistent person #{params[:id]}")
      return
    end
    @user.receive_salmon params[:xml]
  end
  
end
