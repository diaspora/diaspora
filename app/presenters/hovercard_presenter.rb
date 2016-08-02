class HovercardPresenter

  attr_accessor :person, :contact

  # initialize the presenter with the given Person object
  def initialize(person, current_user)
    raise ArgumentError, "the given object is not a Person" unless person.class == Person

    self.person = person
    self.contact = current_user.contact_for(@person)
  end

  # returns the json representation of the Person object for use with the
  # hovercard UI
  def to_json(options={})
    result = {
      :id => person.id,
      :avatar => avatar('medium'),
      :url => profile_url,
      :status_url => Rails.application.routes.url_helpers.new_person_status_message_path(:person_id => person.id),
      :name => person.name,
      :handle => person.diaspora_handle,
      :title => I18n.t('status_messages.new.mentioning', person: person.name),
      :tags => person.tags.map { |t| "#"+t.name },
    }
    result.merge!(message_url: message_url) if  message_url
    return result.to_json(options)
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

  def message_url

    if false
      Rails.application.routes.url_helpers.new_conversation_path(:contact_id => @contact.id, name: @contact.person.name, modal: true)
    else
      return nil
    end

  end
end
