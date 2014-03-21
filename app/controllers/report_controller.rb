class ReportController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unless_admin, :except => [:create]

  def index
    @reports = Report.where(reviewed: false).all
  end

  def update
    if report = Report.where(id: params[:id]).first
      report.mark_as_reviewed
    end
    redirect_to :action => :index
  end

  def destroy
    if report = Report.where(id: params[:id]).first
      if report.destroy_reported_item
        flash[:notice] = I18n.t 'report.status.destroyed'
      else
        flash[:error] = I18n.t 'report.status.failed'
      end
    else
      flash[:error] = I18n.t 'report.status.failed'
    end
    redirect_to :action => :index
  end

  def create
    if current_user.reports.create! report_params
      flash.now[:notice] = I18n.t 'report.status.created'
      render :nothing => true, :status => 200
    else
      flash.now[:error] = I18n.t 'report.status.failed'
      render :nothing => true, :status => 409
    end
  end

  private
    def report_params
      params.require(:report).permit(:post_id, :post_type, :text)
    end
end
