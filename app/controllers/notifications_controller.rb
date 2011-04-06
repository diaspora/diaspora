#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json


  def update
    note = Notification.where(:recipient_id => current_user.id, :id => params[:id]).first
    if note
      note.update_attributes(:unread => false)
      render :nothing => true
    else
      render :nothing => true, :status => 404
    end
  end

  def index
    @notifications = Notification.find(:all, :conditions => {:recipient_id => current_user.id},
                                       :order => 'created_at desc', :include => [:target, {:actors => :profile}]).paginate :page => params[:page], :per_page => 25
    @group_days = @notifications.group_by{|note| I18n.l(note.updated_at, :format => I18n.t('date.formats.fullmonth_day')) }
    respond_with @notifications
  end

  def read_all
    Notification.where(:recipient_id => current_user.id).update_all(:unread => false)
    redirect_to aspects_path
  end
end
