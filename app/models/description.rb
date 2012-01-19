class Description < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/webhooks')
  include Diaspora::Webhooks
  include Diaspora::Taggable
  include ROXML

  attr_accessor :tag_string

  acts_as_taggable_on :tags
  extract_tags_from :tag_string
  validates :tag_list, :length => { :maximum => 5 }

  xml_attr :diaspora_handle
  xml_attr :title
  xml_attr :image_url
  xml_attr :image_url_small
  xml_attr :image_url_medium
  xml_attr :location
  xml_attr :searchable
  xml_attr :tag_string
  xml_attr :lat
  xml_attr :long
  xml_attr :summary


  before_save :strip_names
  after_validation :strip_names

  validates :title, :length => { :maximum => 256 }
  validates :title, :length => { :maximum => 256 }
  validates :title, :length => { :maximum => 256 }

  validates_format_of :first_name, :with => /\A[^;]+\z/, :allow_blank => true
  validates_format_of :last_name, :with => /\A[^;]+\z/, :allow_blank => true
  validate :max_tags
  validate :valid_birthday

  attr_accessible :title, :summary, :image_url, :image_url_medium,
    :image_url_small, :lat, :long, :bio, :location, :searchable, :date, :tag_string

  belongs_to :place
  before_validation do
    self.tag_string = self.tag_string.split[0..4].join(' ')
  end

  before_save do
    self.build_tags
    self.construct_full_name
  end

  def subscribers(user)
    Place.joins(:contacts).where(:contacts => {:user_id => user.id})
  end

  def receive(user, place)
    Rails.logger.info("event=receive payload_type=profile sender=#{person} to=#{user}")
    place.profile.update_attributes self.attributes.merge(:tag_string => self.tag_string)

    place.profile
  end

  def diaspora_handle
    #get the parent diaspora handle, unless we want to access a profile without a person
    (self.place) ? self.place.diaspora_handle : self[:diaspora_handle]
  end

  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
               self[:image_url_medium]
             elsif size == :thumb_small && self[:image_url_small]
               self[:image_url_small]
             else
               self[:image_url]
             end
    result || '/images/user/default.png'
  end

  def image_url= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
      super(absolutify_local_url(url))
    end
  end

  def image_url_small= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
      super(absolutify_local_url(url))
    end
  end

  def image_url_medium= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
      super(absolutify_local_url(url))
    end
  end

  def tag_string
    if @tag_string
      @tag_string
    else
      rows = connection.select_rows( self.tags.scoped.to_sql )
      rows.inject(""){|string, row| string << "##{row[1]} " }
    end
  end

  def tombstone!
    self.taggings.delete_all
    clearable_fields.each do |field|
      self[field] = nil
    end
    self[:searchable] = false
    self.save
  end

  protected

  def max_tags
    if self.tag_string.count('#') > 5
      errors[:base] << 'Profile cannot have more than five tags'
    end
  end

  private
  def clearable_fields
    self.attributes.keys - Profile.protected_attributes.to_a - ["created_at", "updated_at", "person_id"]
  end

  def absolutify_local_url url
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
    "#{pod_url}#{url}"
  end


end

