class HovercardPresenter

  attr_accessor :person

  # initialize the presenter with the given Person object
  def initialize(person)
    raise ArgumentError, "the given object is not a Person" unless person.class == Person

    self.person = person
  end

  # returns the json representation of the Person object for use with the
  # hovercard UI
  def to_json(options={})
    {  :id => person.id,
       :avatar => avatar('medium'),
       :url => profile_url,
       :name => person.name,
       :handle => person.diaspora_handle,
       :tags => person.tags.map { |t| "#"+t.name }
    }.to_json(options)
  end

  # get the image url of the profile avatar for the given size
  # possible sizes: 'small', 'medium', 'large'
  def avatar(size="medium")
    if !["small", "medium", "large"].include?(size)
      raise ArgumentError, "the given parameter is not a valid size"
    end

    person.image_url("thumb_#{size}".to_sym)
  end

  # return the (relative) url to the user profile page.
  # uses the 'person_path' url helper from the rails routes
  def profile_url
    Rails.application.routes.url_helpers.person_path(person)
  end
end
