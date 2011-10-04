class BaseStream
  attr_accessor :max_time, :order, :user

  def initialize(user, opts={})
    self.user = user
    self.max_time = opts[:max_time]
    self.order = opts[:order] 
  end


  
  #requied to implement said stream
  def link(opts={})
    Rails.application.routes.url_helpers.mentions_path(opts)
  end

  def can_comment?(post)
    true
  end

  def title
    'a title'
  end

  def posts
    []
  end

  def people
    []
  end

  def contacts_title
    "title for a stream"
  end

  def contacts_link
    '#'
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
end
