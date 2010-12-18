#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show
  respond_to :js

  def index
    @posts  = current_user.visible_posts(:_type => "StatusMessage").paginate :page => params[:page], :per_page => 15, :order => 'created_at DESC'
    @post_hashes = hashes_for_posts @posts
    @contacts = Contact.all(:user_id => current_user.id, :pending => false)
    @aspect_hashes = hashes_for_aspects @aspects.all, @contacts, :limit => 8
    @aspect = :all

    @contact_hashes = hashes_for_contacts @contacts

    if current_user.getting_started == true
      redirect_to getting_started_path
    end
  end

  def create
    @aspect = current_user.aspects.create(params[:aspect])
    if @aspect.valid?
      flash[:notice] = I18n.t('aspects.create.success', :name => @aspect.name)
      if current_user.getting_started
        redirect_to :back
      elsif request.env['HTTP_REFERER'].include?("aspects/manage")
        redirect_to :back
      else
        respond_with @aspect
      end
    else
      flash[:error] = I18n.t('aspects.create.failure')
      redirect_to :back
    end
  end

  def new
    @aspect = Aspect.new
  end

  def destroy
    @aspect = current_user.aspect_by_id params[:id]

    begin
      current_user.drop_aspect @aspect
      flash[:notice] = I18n.t 'aspects.destroy.success',:name => @aspect.name
      redirect_to root_url
    rescue RuntimeError => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  def show
    @aspect = current_user.aspect_by_id params[:id]
    @contacts = current_user.contacts(:pending => false)
    unless @aspect
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    else
      @aspect_contacts = hashes_for_contacts Contact.all(:user_id => current_user.id, :aspect_ids.in => [@aspect.id], :pending => false)
      @aspect_contacts_count = @aspect_contacts.count

      @all_contacts = hashes_for_contacts @contacts

      @posts = @aspect.posts.find_all_by__type("StatusMessage", :order => 'created_at desc').paginate :page => params[:page], :per_page => 15
      @post_hashes = hashes_for_posts @posts
      @post_count = @posts.count

      respond_with @aspect
    end
  end

  def manage
    @aspect = :manage
    @contacts = current_user.contacts(:pending => false)
    @remote_requests = Request.hashes_for_person(current_user.person)
    @aspect_hashes = hashes_for_aspects @aspects, @contacts
  end

  def update
    @aspect = current_user.aspect_by_id(params[:id])
    if @aspect.update_attributes( params[:aspect] )
      flash[:notice] = I18n.t 'aspects.update.success',:name => @aspect.name
    else
      flash[:error] = I18n.t 'aspects.update.failure',:name => @aspect.name
    end
    respond_with @aspect
  end

  def move_contact
    @person = Person.find(params[:person_id])
    @from_aspect = current_user.aspects.find(params[:from])
    @to_aspect = current_user.aspects.find(params[:to][:to])

    unless current_user.move_contact( @person, @from_aspect, @to_aspect)
      flash[:error] = I18n.t 'aspects.move_contact.error',:inspect => params.inspect
    end
    if aspect = current_user.aspect_by_id(params[:to][:to])
      flash[:notice] = I18n.t 'aspects.move_contact.success'
      render :nothing => true
    else
      flash[:notice] = I18n.t 'aspects.move_contact.failure'
      render aspects_manage_path
    end
  end

  def add_to_aspect
    @person = Person.find(params[:person_id])
    @aspect = current_user.aspects.find(params[:aspect_id])
    @contact = current_user.contact_for(@person)

    if @contact
      current_user.add_contact_to_aspect(@contact, @aspect)
    else
      current_user.send_contact_request_to(@person, @aspect)
      contact = current_user.contact_for(@person)

      if request = Request.from(@person).to(current_user).first
        request.destroy
        contact.update_attributes(:pending => false)
      end
    end
    flash.now[:notice] =  I18n.t 'aspects.add_to_aspect.success'

    respond_to do |format|
      format.js { render :json => {
        :button_html => render_to_string(:partial => 'aspects/add_to_aspect',
                         :locals => {:aspect_id => @aspect.id,
                                     :person_id => @person.id}),
        :badge_html =>  render_to_string(:partial => 'aspects/aspect_badge',
                            :locals => {:aspect => @aspect})
        }}
      format.html{ redirect_to aspect_path(@aspect.id)}
    end
  end

  def remove_from_aspect
    begin current_user.delete_person_from_aspect(params[:person_id], params[:aspect_id])
      @person_id = params[:person_id]
      @aspect_id = params[:aspect_id]
      flash.now[:notice] = I18n.t 'aspects.remove_from_aspect.success'

      respond_to do |format|
        format.js { render :json => {:button_html =>
          render_to_string(:partial => 'aspects/remove_from_aspect',
                           :locals => {:aspect_id => @aspect_id,
                                       :person_id => @person_id}),
          :aspect_id => @aspect_id
        }}
        format.html{
          redirect_to :back
        }
      end
    rescue Exception => e
      flash.now[:error] = I18n.t 'aspects.remove_from_aspect.failure'

      respond_to do |format|
        format.js  { render :text => e, :status => 403 }
        format.html{
          redirect_to :back
        }
      end
    end
  end

  private
  def hashes_for_contacts contacts
    people = Person.all(:id.in => contacts.map{|c| c.person_id}, :fields => [:profile, :diaspora_handle])
    people_hash = {}
    people.each{|p| people_hash[p.id] = p}
    contacts.map{|c| {:contact => c, :person => people_hash[c.person_id.to_id]}}
  end

  def hashes_for_aspects aspects, contacts, opts = {}
    contact_hashes = hashes_for_contacts contacts
    aspects.map do |a|
      hash = {:aspect => a}
      aspect_contact_hashes = contact_hashes.select{|c|
          c[:contact].aspect_ids.include?(a.id)}
      hash[:contact_count] = aspect_contact_hashes.count
      if opts[:limit]
        hash[:contacts] = aspect_contact_hashes.slice(0,opts[:limit])
      else
        hash[:contacts] = aspect_contact_hashes
      end
      hash
    end
  end
  def hashes_for_posts posts
    post_ids = []
    post_person_ids = []
    posts.each{|p| post_ids << p.id; post_person_ids << p.person_id}

    comment_hash = Comment.hash_from_post_ids post_ids
    commenters_hash = Person.from_post_comment_hash comment_hash
    photo_hash = Photo.hash_from_post_ids post_ids

    post_person_ids.uniq!
    posters = Person.all(:id.in => post_person_ids, :fields => [:profile, :owner_id, :diaspora_handle])
    posters_hash = {}
    posters.each{|poster| posters_hash[poster.id] = poster}

    posts.map do |post|
      {:post => post,
        :photos => photo_hash[post.id],
        :person => posters_hash[post.person_id],
        :comments => comment_hash[post.id].map do |comment|
          {:comment => comment,
            :person => commenters_hash[comment.person_id],
          }
        end,
      }
    end
  end
end
