class StatisticsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unauthorized
  
  def index
    @statistics = Statistic.find(:all, :order => 'created_at DESC').paginate(:page => params[:page], :per_page => 15)
  end

  def show
    @statistic = Statistic.where(:id => params[:id]).first
    @distribution = @statistic.distribution_as_array
  end

  def generate_single
    stat = Statistic.generate()
    redirect_to stat
  end

  def graph
    # need to use google's graph API
  end

  private
  def redirect_unauthorized
    unless AppConfig[:admins].include?(current_user.username)
      redirect_to root_url
    end
  end
end

