module PeopleHelper
  
  def search_or_index
    if params[:q]
      " results for #{params[:q]}"
    else
      " people on pod is aware of"
    end
    
  end
end
