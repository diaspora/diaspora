class BaseStream
  TYPES_OF_POST_IN_STREAM = ['StatusMessage', 'Reshare', 'ActivityStreams::Photo']
  attr_accessor :max_time, :order, :user

  def initialize(user, opts={})
    self.user = user
    self.max_time = opts[:max_time]
    self.order = opts[:order] 
  end

  def random_featured_user
    @random_featured_user ||= Person.find_by_diaspora_handle(featured_diaspora_id)
  end

  def has_featured_users?
    random_featured_user.present?
  end
  
  #requied to implement said stream
  def link(opts={})
    'change me in lib/base_stream.rb!'
  end

  def can_comment?(post)
    true
  end

  def title
    'change me in lib/base_stream.rb!'
  end

  def posts
    []
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    people_ids = posts.map{|x| x.author_id}
    Person.where(:id => people_ids).includes(:profile)
  end

  def contacts_link_title
    I18n.translate('aspects.selected_contacts.view_all_contacts')
  end

  def contacts_title
    'change me in lib/base_stream.rb!'
  end

  def contacts_link
    'change me in lib/base_stream.rb!'
  end

  #helpers
  def ajax_stream?
    false
  end
  
  def for_all_aspects?
    true
  end


  #NOTE: MBS bad bad methods the fact we need these means our views are foobared. please kill them and make them 
  #private methods on the streams that need them
  def aspects
    @user.aspects
  end

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
  def featured_diaspora_id
    @featured_diaspora_id ||= AppConfig[:featured_users].sample(1)
  end
end
