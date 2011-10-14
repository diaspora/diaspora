class Stream::Base
  TYPES_OF_POST_IN_STREAM = ['StatusMessage', 'Reshare', 'ActivityStreams::Photo']
  attr_accessor :max_time, :order, :user

  def initialize(user, opts={})
    self.user = user
    self.max_time = opts[:max_time]
    self.order = opts[:order] 
  end

  # @return [Person]
  def random_featured_user
    @random_featured_user ||= Person.find_by_diaspora_handle(featured_diaspora_id)
  end

  # @return [Boolean]
  def has_featured_users?
    random_featured_user.present?
  end
  
  #requied to implement said stream
  def link(opts={})
    'change me in lib/base_stream.rb!'
  end

  # @return [Boolean]
  def can_comment?(post)
    return true if post.author.local?
    post_is_from_contact?(post)
  end

  # @return [String]
  def title
    'a title'
  end

  # @return [ActiveRecord::Relation<Post>]
  def posts
    []
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    people_ids = posts.map{|x| x.author_id}
    Person.where(:id => people_ids).includes(:profile)
  end

  # @return [String]
  def contacts_link_title
    I18n.translate('aspects.selected_contacts.view_all_contacts')
  end

  # @return [String]
  def contacts_title
    'change me in lib/base_stream.rb!'
  end

  # @return [String]
  def contacts_link
    '#'
  end

  #helpers
  # @return [Boolean]
  def ajax_stream?
    false
  end

  # @return [Boolean]
  def for_all_aspects?
    true
  end


  #NOTE: MBS bad bad methods the fact we need these means our views are foobared. please kill them and make them 
  #private methods on the streams that need them
  def aspects
    user.aspects
  end

  # @return [Aspect] The first aspect in #aspects
  def aspect
    aspects.first
  end
  
  def aspect_ids
    aspects.map{|x| x.id} 
  end

  def max_time=(time_string)
    @max_time = Time.at(time_string.to_i) unless time_string.blank?
    @max_time ||= (Time.now + 1)
  end

  def order=(order_string)
    @order = order_string
    @order ||= 'created_at'
  end

  private

  # Memoizes all Contacts present in the Stream
  #
  # @return [Array<Contact>]
  def contacts_in_stream
    @contacts_in_stream ||= Contact.where(:user_id => user.id, :person_id => people.map{|x| x.id}).all
  end

  def featured_diaspora_id
    @featured_diaspora_id ||= AppConfig[:featured_users].try(:sample, 1)
  end

  # @param post [Post]
  # @return [Boolean]
  def post_is_from_contact?(post)
    @can_comment_cache ||= {}
    @can_comment_cache[post.id] ||= contacts_in_stream.find{|contact| contact.person_id == post.author.id}.present?
    @can_comment_cache[post.id] ||= user.person.id == post.author.id
    @can_comment_cache[post.id]
  end
end
