class StatisticsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_unauthorized
  
  def index
    @statistics = Statistic.find(:all, :order => 'created_at DESC').paginate(:page => params[:page], :per_page => 15)
  end

  def show
    @statistic = Statistic.where(:id => params[:id]).first
    @distribution = @statistic.distribution_as_array
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.series(:name=>'Posts on day', :data=> @distribution)
      f.options[:x_axis][:categories] = (0..@distribution.length-1).to_a.map{|ind| ind%10==0 ? ind : ' '}

      f.options[:title] = "Posts on day"
      f.options[:y_axis] = {:max => 1}
      f.options[:y_axis][:title] = {:text => "% Users"}
      f.options[:x_axis][:title] = {:text => "Posts"}
    end
  end

  def generate_single
    stat = Statistic.generate()
    redirect_to stat
  end

  private
  def redirect_unauthorized
    unless AppConfig[:admins].include?(current_user.username)
      redirect_to root_url
    end
  end
end

