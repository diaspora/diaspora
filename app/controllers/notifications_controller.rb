#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < VannaController
  include NotificationsHelper

  include ActionController::MobileFu
  has_mobile_fu

  def update(opts=params)
    note = Notification.where(:recipient_id => current_user.id, :id => opts[:id]).first
    if note
      note.update_attributes(:unread => false)
      {}
    else
      Response.new :status => 404
    end
  end

  def index(opts=params)
    @aspect = :notification
    conditions = {:recipient_id => current_user.id}
    page = opts[:page] || 1
    per_page = opts[:per_page] || 25
    notifications = WillPaginate::Collection.create(page, per_page, Notification.where(conditions).count ) do |pager|
      result = Notification.find(:all,
                                 :conditions => conditions,
                                 :order => 'created_at desc',
                                 :include => [:target, {:actors => :profile}],
                                 :limit => pager.per_page,
                                 :offset => pager.offset
                                )

      pager.replace(result)
    end
    notifications.each do |n|
      n[:actors] = n.actors
      n[:translation] = notification_message_for(n)
      n[:translation_key] = n.popup_translation_key
      n[:target] = n.translation_key == "notifications.mentioned" ? n.target.post : n.target
    end
    group_days = notifications.group_by{|note| I18n.l(note.created_at, :format => I18n.t('date.formats.fullmonth_day')) }
    {:group_days => group_days, :notifications => notifications}
  end

  def read_all(opts=params)
    Notification.where(:recipient_id => current_user.id).update_all(:unread => false)
  end

  post_process :html do
    def post_read_all(json)
      Response.new(:status => 302, :location => multi_stream_path)
    end
  end

  def controller
    Object.new
  end
end
