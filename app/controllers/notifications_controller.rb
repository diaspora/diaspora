#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json, only: :counts

  def update
    note = Notification.where(:recipient_id => current_user.id, :id => params[:id]).first
    if note
      note.set_read_state(params[:set_unread] != "true" )

      respond_to do |format|
        format.json { render :json => { :guid => note.id, :unread => note.unread } }
      end

    else
      respond_to do |format|
        format.json { render :json => {}.to_json }
      end
    end
  end

  def index
    conditions = {:recipient_id => current_user.id}
    if params[:type] && Notification.types.has_key?(params[:type])
      conditions[:type] = Notification.types[params[:type]]
    end
    if params[:show] == "unread" then conditions[:unread] = true end
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    @notifications = WillPaginate::Collection.create(page, per_page, Notification.where(conditions).count ) do |pager|
      result = Notification.where(conditions)
                           .includes(:target, :actors => :profile)
                           .order('created_at desc')
                           .limit(pager.per_page)
                           .offset(pager.offset)

      pager.replace(result)
    end
    @notifications.each do |note|
      note.note_html = render_to_string( :partial => 'notification', :locals => { :note => note } )
    end
    @group_days = @notifications.group_by{|note| note.created_at.strftime('%Y-%m-%d')}

    @unread_notification_count = current_user.unread_notifications.count

    @grouped_unread_notification_counts = {}

    Notification.types.each_with_object(current_user.unread_notifications.group_by(&:type)) {|(name, type), notifications|
      @grouped_unread_notification_counts[name] = notifications.has_key?(type) ? notifications[type].count : 0
    }

    respond_to do |format|
      format.html
      format.xml { render :xml => @notifications.to_xml }
      format.json { render :json => @notifications.to_json }
    end

  end

  def read_all
    current_type = Notification.types[params[:type]]
    notifications = Notification.where(:recipient_id => current_user.id)
    notifications = notifications.where(:type => current_type) if params[:type]
    notifications.update_all(:unread => false)
    respond_to do |format|
      if current_user.unread_notifications.count > 0
        format.html { redirect_to notifications_path }
        format.mobile { redirect_to notifications_path }
      else
        format.html { redirect_to stream_path }
        format.mobile { redirect_to stream_path }
      end
      format.xml { render :xml => {}.to_xml }
      format.json { render :json => {}.to_json }
    end

  end

  def counts
    render json: {
      notifications: current_user.unread_notifications.count
    }
  end
end
