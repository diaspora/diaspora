module DashboardsHelper

  def title_for_page
    if params[:action] =='ostatus'
      'OStatus Dashboard'
    else
      'Dashboard' 
    end
  end
end
