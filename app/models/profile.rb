# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Profile < ApplicationRecord
  MAX_TAGS = 5
  self.include_root_in_json = false

  include Diaspora::Federated::Base
  include Diaspora::Taggable

  attr_accessor :tag_string
  acts_as_ordered_taggable
  extract_tags_from :tag_string
  validates :tag_list, :length => { :maximum => 5 }

  before_save :strip_names
  after_validation :strip_names

  validates :first_name, :length => { :maximum => 32 }
  validates :last_name, :length => { :maximum => 32 }
  validates :location, :length => { :maximum =>255 }
  validates :gender, length: {maximum: 255}

  validates_format_of :first_name, :with => /\A[^;]+\z/, :allow_blank => true
  validates_format_of :last_name, :with => /\A[^;]+\z/, :allow_blank => true
  validate :max_tags
  validate :valid_birthday

  belongs_to :person
  before_validation do
    self.tag_string = self.tag_string.split[0..4].join(' ')
    self.build_tags
  end

  before_save do
    self.build_tags
    self.construct_full_name
  end

  def subscribers
    Person.joins(:contacts).where(contacts: {user_id: person.owner_id})
  end

  def public?
    public_details?
  end

  def diaspora_handle
    #get the parent diaspora handle, unless we want to access a profile without a person
    (self.person) ? self.person.diaspora_handle : self[:diaspora_handle]
  end

  def image_url(size: :thumb_large, fallback_to_default: true)
    result = if size == :thumb_medium && self[:image_url_medium]
               self[:image_url_medium]
             elsif size == :thumb_small && self[:image_url_small]
               self[:image_url_small]
             else
               self[:image_url]
             end

    if result
      if AppConfig.privacy.camo.proxy_remote_pod_images?
        Diaspora::Camo.image_url(result)
      else
        result
      end
    elsif fallback_to_default
      ActionController::Base.helpers.image_path("user/default.png")
    end
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

  def image_url=(url)
    super(build_image_url(url))
  end

  def image_url_small=(url)
    super(build_image_url(url))
  end

  def image_url_medium=(url)
    super(build_image_url(url))
  end

  def date= params
    if %w(month day).all? {|key| params[key].present? }
      params["year"] = "1004" if params["year"].blank?
      if Date.valid_civil?(params["year"].to_i, params["month"].to_i, params["day"].to_i)
        self.birthday = Date.new(params["year"].to_i, params["month"].to_i, params["day"].to_i)
      else
        @invalid_birthday_date = true
      end
    elsif %w(year month day).all? {|key| params[key].blank? }
      self.birthday = nil
    end
  end

  def bio_message
    @bio_message ||= Diaspora::MessageRenderer.new(bio)
  end

  def location_message
    @location_message ||= Diaspora::MessageRenderer.new(location)
  end

  def tag_string
    @tag_string ||= tags.pluck(:name).map {|tag| "##{tag}" }.join(" ")
  end

  # Constructs a full name by joining #first_name and #last_name
  # @return [String] A full name
  def construct_full_name
    self.full_name = [self.first_name, self.last_name].join(' ').downcase.strip
    self.full_name
  end

  def tombstone!
    @tag_string = nil
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
    attributes.keys - %w[id created_at updated_at person_id tag_list]
  end

  def build_image_url(url)
    return nil if url.blank? || url.match(/user\/default/)
    return url if url.match(/^https?:\/\//)
    "#{AppConfig.pod_uri.to_s.chomp('/')}#{url}"
  end
end
