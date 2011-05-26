#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < VannaController


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
    @aspect = :notification
    conditions = {:recipient_id => current_user.id}
    page = params[:page] || 1
    notifications = WillPaginate::Collection.create(page, 25, Notification.where(conditions).count ) do |pager|
      result = Notification.find(:all,
                                 :conditions => conditions,
                                 :order => 'created_at desc',
                                 :include => [:target, {:actors => :profile}],
                                 :limit => pager.per_page,
                                 :offset => pager.offset
                                )

      pager.replace(result)
    end

    group_days = notifications.group_by{|note| I18n.l(note.created_at, :format => I18n.t('date.formats.fullmonth_day')) }
    {:group_days => group_days, :current_user => current_user, :notifications => notifications}
  end

  def read_all
    Notification.where(:recipient_id => current_user.id).update_all(:unread => false)
    redirect_to aspects_path
  end
end
