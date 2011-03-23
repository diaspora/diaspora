class ApisController < ApplicationController #ActionController::Metal
  #include ActionController::Rendering
  #include ActionController::Renderers::All

  respond_to :json
  
  #posts
  def public_timeline
    set_defaults
    timeline = StatusMessage.where(:public => true).includes(:photos, :author => :profile).paginate(:page => params[:page], :per_page => params[:per_page], :order => "#{params[:order]} DESC")
    respond_with timeline do |format|
      format.json{ render :json => timeline.to_json(:format => :twitter) }
    end
  end

  def user_timeline
    set_defaults
    if params[:user_id]
      if person = Person.find(params[:user_id])
        timeline = person.posts.where(:type => "StatusMessage", :public => true).paginate(:page => params[:page], :per_page => params[:per_page], :order => "#{params[:order]} DESC")
      end
    end
    respond_with timeline
  end

  def statuses
    status = StatusMessage.where(:guid => params[:guid], :public => true).includes(:photos, :author => :profile).first
    if status
      respond_with status do |format|
        format.json{ render :json => status.to_json(:format => :twitter) }
      end
    else
      render(:nothing => true, :status => 404) 
    end
  end

  #people
  def users
    if params[:user_id]
      person = Person.where(:id => params[:user_id]).first
    elsif params[:screen_name]
      person = Person.where(:diaspora_handle => params[:screen_name]).first
    end

    if person
      respond_with person do |format|
        format.json{ render :json => person.to_json(:format => :twitter) }
      end
    else
      render(:nothing => true, :status => 404) 
    end
  end

  def users_search
    set_defaults

    if params[:q]
      people = Person.public_search(params[:q]).paginate(:page => params[:page], :per_page => params[:per_page], :order => "#{params[:order]} DESC")
    end

    if people
      respond_with people do |format|
        format.json{ render :json => people.to_json(:format => :twitter) }
      end
    else
      render(:nothing => true, :status => 404) 
    end
  end


  #tags
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

  protected
  def set_defaults
    params[:per_page] ||= 20
    params[:order] ||= 'created_at'
    params[:page] ||= 1
  end
end
