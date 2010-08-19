module PeopleHelper
  
  def search_or_index
    if params[:q]
      " results for #{q}"
    else
      " people on this pod"
    end
    
  end
end