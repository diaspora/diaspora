#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Profile < ActiveRecord::Base
  self.include_root_in_json = false

  include Diaspora::Federated::Base
  include Diaspora::Taggable

  attr_accessor :tag_string
  acts_as_taggable_on :tags
  extract_tags_from :tag_string
  validates :tag_list, :length => { :maximum => 5 }

  xml_attr :diaspora_handle
  xml_attr :first_name
  xml_attr :last_name
  xml_attr :image_url
  xml_attr :image_url_small
  xml_attr :image_url_medium
  xml_attr :birthday
  xml_attr :gender
  xml_attr :bio
  xml_attr :location
  xml_attr :searchable
  xml_attr :nsfw
  xml_attr :tag_string

  before_save :strip_names
  after_validation :strip_names

  validates :first_name, :length => { :maximum => 32 }
  validates :last_name, :length => { :maximum => 32 }

  validates_format_of :first_name, :with => /\A[^;]+\z/, :allow_blank => true
  validates_format_of :last_name, :with => /\A[^;]+\z/, :allow_blank => true
  validate :max_tags
  validate :valid_birthday

  belongs_to :person
  before_validation do
    self.tag_string = self.tag_string.split[0..4].join(' ')
  end

  before_save do
    self.build_tags
    self.construct_full_name
  end

  def subscribers(user)
    Person.joins(:contacts).where(:contacts => {:user_id => user.id})
  end

  def receive(user, person)
    Rails.logger.info("event=receive payload_type=profile sender=#{person} to=#{user}")
    profiles_attr = self.attributes.merge('tag_string' => self.tag_string).slice('diaspora_handle', 'first_name', 'last_name', 'image_url', 'image_url_small', 'image_url_medium', 'birthday', 'gender', 'bio', 'location', 'searchable', 'nsfw', 'tag_string')
    person.profile.update_attributes(profiles_attr)

    person.profile
  end

  def diaspora_handle
    #get the parent diaspora handle, unless we want to access a profile without a person
    (self.person) ? self.person.diaspora_handle : self[:diaspora_handle]
  end

  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
               self[:image_url_medium]
             elsif size == :thumb_small && self[:image_url_small]
               self[:image_url_small]
             else
               self[:image_url]
             end
    result || '/assets/user/default.png'
  end

  def from_omniauth_hash(omniauth_user_hash)
    mappings = {"description" => "bio",
               'image' => 'image_url',
               'name' => 'first_name',
               'location' =>  'location',
                }

    update_hash = Hash[ omniauth_user_hash.map {|k, v| [mappings[k], v] } ]

    self.attributes.merge(update_hash){|key, old, new| old.blank? ? new : old}
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

  def date= params
    if ['month', 'day'].all? { |key| params[key].present?  }
      params['year'] = '1000' if params['year'].blank?
      if Date.valid_civil?(params['year'].to_i, params['month'].to_i, params['day'].to_i)
        self.birthday = Date.new(params['year'].to_i, params['month'].to_i, params['day'].to_i)
      else
        @invalid_birthday_date = true
      end
    elsif [ 'year', 'month', 'day'].all? { |key| params[key].blank? }
      self.birthday = nil
    end
  end

  def formatted_birthday
    birthday.to_s(:long).gsub(', 1000', '') if birthday.present?
  end

  def bio_message
    @bio_message ||= Diaspora::MessageRenderer.new(bio)
  end

  def location_message
    @location_message ||= Diaspora::MessageRenderer.new(location)
  end

  def tag_string
    if @tag_string
      @tag_string
    else
      rows = self.class.connection.select_rows( self.tags.scoped.to_sql )
      rows.inject(""){|string, row| string << "##{row[1]} " }
    end
  end

  # Constructs a full name by joining #first_name and #last_name
  # @return [String] A full name
  def construct_full_name
    self.full_name = [self.first_name, self.last_name].join(' ').downcase.strip
    self.full_name
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
  def strip_names
    self.first_name.strip! if self.first_name
    self.last_name.strip! if self.last_name
  end

  def max_tags
    if self.tag_string.count('#') > 5
      errors[:base] << 'Profile cannot have more than five tags'
    end
  end

  def valid_birthday
    if @invalid_birthday_date
      errors.add(:birthday)
      @invalid_birthday_date = nil
    end
  end

  private
  def clearable_fields
    self.attributes.keys - Profile.protected_attributes.to_a - ["created_at", "updated_at", "person_id"]
  end

  def absolutify_local_url url
    "#{AppConfig.pod_uri.to_s.chomp("/")}#{url}"
  end
end
