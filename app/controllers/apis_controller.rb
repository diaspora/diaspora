class ApisController < ActionController::Metal
  include ActionController::Rendering
  include ActionController::Renderers::All
  
## posts
  def posts_index
    set_defaults
    sm = StatusMessage.where(:public => true).includes(:photos, :author => :profile).paginate(:page => params[:page], :per_page => params[:per_page], :order => "#{params[:order]} DESC")
    render :json => sm.to_json
  end

  def posts
    sm = StatusMessage.where(:guid => params[:guid], :public => true).includes(:photos, :author => :profile).first
    if sm
      render :json => sm.to_json
    else
      render(:nothing => true, :status => 404) 
    end
  end

  #tags
  #
  def tag_posts
    set_defaults
    posts = StatusMessage.where(:public => true, :pending => false)
    posts = posts.tagged_with(params[:tag])
    posts = posts.includes(:comments, :photos).paginate(:page => params[:page], :per_page => params[:per_page], :order => "#{params[:order]} DESC")
    render :json => posts.as_json
  end

  def tag_people
    set_defaults
    profiles = Profile.tagged_with(params[:tag]).where(:searchable => true).select('profiles.id, profiles.person_id')
    people = Person.where(:id => profiles.map{|p| p.person_id}).paginate(:page => params[:page], :per_page => params[:per_page], :order => "#{params[:order]} DESC")
    render :json => people.as_json
  end

  ##people
  def people_index
    set_defaults
    people = Person.search(params[:q], nil).paginate(:page => params[:page], :per_page => params[:per_page], :order => "#{params[:order]} DESC")
    render :json => people.as_json
  end

  def people
    person = Person.where(:diaspora_handle => params[:diaspora_handle]).first
    if person
        render :json => person.as_json
    else
      render(:nothing => true, :status => 404) 
    end
  end

  protected

  def set_defaults
    params[:per_page] ||= 15
    params[:order] ||= 'created_at'
    params[:page] ||= 1
  end
end
