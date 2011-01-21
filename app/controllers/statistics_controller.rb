class StatisticsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @statistics = Statistic.find(:all, :order => 'created_at DESC').paginate(:page => params[:page], :per_page => 15)
  end

  def show
    @statistic = Statistic.where(:id => params[:id]).first
  end

  def generate_single
    stat = Statistic.generate()
    redirect_to stat
  end

  def graph
    @statistic = Statistic.where(:id => params[:id]).first
    send_data(@statistic.generate_graph, 
            :disposition => 'inline', 
            :type => 'image/png', 
            :filename => "stats.png")
  end
end

