module DashboardsHelper

  def title_for_page
    if params[:action] =='ostatus'
      'OStatus home'
    else
      'home'
    end
  end
end
