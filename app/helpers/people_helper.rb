module PeopleHelper
  
  def search_or_index
    if params[:q]
      " results for #{params[:q]}"
    else
      " people on this pod"
    end
    
  end
end
