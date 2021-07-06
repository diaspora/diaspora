# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ReportController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_unless_moderator, except: [:create]

  def index
    @unreviewed_reports = Report.join_originator.where(reviewed: false).order(created_at: :desc)
    @reviewed_reports = Report.join_originator.where(reviewed: true).order(created_at: :desc)
    @statistics_by_reporter = statistics_by_reporter
    @statistics_by_originator = statistics_by_originator
  end

  def update
    if report = Report.where(id: params[:id]).first
      report.mark_as_reviewed
      report.update(action: "No Action")
    end
    redirect_to :action => :index
  end

  def destroy
    if (report = Report.where(id: params[:id]).first) && report.destroy_reported_item
      flash[:notice] = I18n.t "report.status.destroyed"
    else
      flash[:error] = I18n.t "report.status.failed"
    end
    redirect_to action: :index
  end

  def create
    report = current_user.reports.new(report_params)
    report.originator_diaspora_handle = report.reported_author.diaspora_handle
    if report.save
      render json: true, status: 200
    else
      head :conflict
    end
  end

  private

  def report_params
    params.require(:report).permit(:item_id, :item_type, :text)
  end

  def statistics_by_reporter
    sql = "select count(*), diaspora_handle, guid from reports
           join people on reports.user_id = people.owner_id
           group by diaspora_handle, guid order by 1 desc"
    ActiveRecord::Base.connection.exec_query sql
  end

  def statistics_by_originator
    sql = "select count(*), originator_diaspora_handle, guid from reports
           left join people on originator_diaspora_handle = people.diaspora_handle
           where originator_diaspora_handle is not null
           group by originator_diaspora_handle, guid order by 1 desc"
    ActiveRecord::Base.connection.exec_query sql
  end
end
