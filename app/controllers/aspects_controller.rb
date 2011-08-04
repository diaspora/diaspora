#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :save_sort_order, :only => :index
  before_filter :ensure_page, :only => :index

  respond_to :html, :js
  respond_to :json, :only => [:show, :create]

  helper_method :tags, :tag_followings
  helper_method :all_aspects_selected?

  def index
    if params[:a_ids]
      @aspects = current_user.aspects.where(:id => params[:a_ids])
    else
      @aspects = current_user.aspects
    end

    aspect_ids = @aspects.map{|a| a.id}

    # redirect to aspects creation
    if @aspects.blank?
      redirect_to new_aspect_path
      return
    end

    unless params[:only_posts]
      all_selected_people = Person.joins(:contacts => :aspect_memberships).
        where(:contacts => {:user_id => current_user.id},
              :aspect_memberships => {:aspect_id => aspect_ids})
      @selected_people = all_selected_people.select("DISTINCT people.*").order('RAND()').limit(20).includes(:profile)
    end

    @aspect_ids = @aspects.map { |a| a.id }
    @posts = current_user.visible_posts(:by_members_of => @aspect_ids,
                                           :type => ['StatusMessage','Reshare', 'ActivityStreams::Photo'],
                                           :order => session[:sort_order] + ' DESC',
                                           :max_time => params[:max_time].to_i
                          ).includes(:mentions => {:person => :profile}, :author => :profile)

    if params[:only_posts]
      render :partial => 'shared/stream', :locals => {:posts => @posts}
    else
      @contact_count = current_user.contacts.receiving.count

      @aspect = :all unless params[:a_ids]
      @aspect ||= @aspects.first # used in mobile
    end
  end

  def create
    @aspect = current_user.aspects.create(params[:aspect])

    if @aspect.valid?
      flash[:notice] = I18n.t('aspects.create.success', :name => @aspect.name)
      if current_user.getting_started
        redirect_to :back
      elsif request.env['HTTP_REFERER'].include?("contacts")
        redirect_to :back
      elsif params[:aspect][:person_id]
        @person = Person.where(:id => params[:aspect][:person_id]).first

        if @contact = current_user.contact_for(@person)
          @contact.aspects << @aspect
        else
          @contact = current_user.share_with(@person, @aspect)
        end
      else
        redirect_to contacts_path(:a_id => @aspect.id)
      end
    else
      respond_to do |format|
        format.js { render :text => I18n.t('aspects.create.failure'), :status => 422 }
        format.html do
          flash[:error] = I18n.t('aspects.create.failure')
          redirect_to :back
        end
      end
    end
  end

  def new
    @aspect = Aspect.new
    @person_id = params[:person_id]
    respond_to do |format|
      format.js { render :layout => false }
      format.html { render '_new' }
    end
  end

  def destroy
    @aspect = current_user.aspects.where(:id => params[:id]).first

    begin
      @aspect.destroy
      flash[:notice] = I18n.t 'aspects.destroy.success', :name => @aspect.name
      redirect_to aspects_path
    rescue ActiveRecord::StatementInvalid => e
      flash[:error] = I18n.t 'aspects.destroy.failure', :name => @aspect.name
      redirect_to aspects_path
    end
  end

  def show
    @aspect = current_user.aspects.where(:id => params[:id]).first
    if @aspect
      redirect_to aspects_path('a_ids[]' => @aspect.id)
    else
      redirect_to aspects_path
    end
  end

  def edit
    @aspect = current_user.aspects.where(:id => params[:id]).includes(:contacts => {:person => :profile}).first

    @contacts_in_aspect = @aspect.contacts.includes(:aspect_memberships, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    c = Contact.arel_table
    if @contacts_in_aspect.empty?
      @contacts_not_in_aspect = current_user.contacts.includes(:aspect_memberships, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    else
      @contacts_not_in_aspect = current_user.contacts.where(c[:id].not_in(@contacts_in_aspect.map(&:id))).includes(:aspect_memberships, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    end

    @contacts = @contacts_in_aspect + @contacts_not_in_aspect

    unless @aspect
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @aspect_ids = [@aspect.id]
      @aspect_contacts_count = @aspect.contacts.size
      render :layout => false
    end
  end

  def update
    @aspect = current_user.aspects.where(:id => params[:id]).first

    if @aspect.update_attributes!(params[:aspect])
      flash[:notice] = I18n.t 'aspects.update.success', :name => @aspect.name
    else
      flash[:error] = I18n.t 'aspects.update.failure', :name => @aspect.name
    end
    render :nothing => true, :status => 204
  end

  def toggle_contact_visibility
    @aspect = current_user.aspects.where(:id => params[:aspect_id]).first

    if @aspect.contacts_visible?
      @aspect.contacts_visible = false
    else
      @aspect.contacts_visible = true
    end
    @aspect.save
  end

  def ensure_page
    params[:max_time] ||= Time.now + 1
  end

  def all_aspects_selected?
    @aspect == :all
  end

  def tag_followings
    if current_user
      if @tag_followings == nil
        @tag_followings = current_user.tag_followings
      end
      @tag_followings
    end
  end

  def tags
    @tags ||= current_user.followed_tags
  end

  private
  def save_sort_order
    if params[:sort_order].present?
      session[:sort_order] = (params[:sort_order] == 'created_at') ? 'created_at' : 'updated_at'
    elsif session[:sort_order].blank?
      session[:sort_order] = 'updated_at'
    else
      session[:sort_order] = (session[:sort_order] == 'created_at') ? 'created_at' : 'updated_at'
    end
  end

end
