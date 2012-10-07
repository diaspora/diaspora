class PersonPresenter
  def initialize(person, current_user = nil)
    @person = person
    @current_user = current_user
  end

  def as_json(options={})
    attrs = @person.as_api_response(:backbone).merge(
        {
            :is_own_profile => is_own_profile
        })

    if is_own_profile || person_is_following_current_user
      attrs.merge!({
                      :location => @person.location,
                      :birthday => @person.formatted_birthday,
                      :bio => @person.bio
                  })
    end

    attrs
  end

  def is_own_profile
    @current_user.try(:person) == @person
  end

  protected

  def person_is_following_current_user
    @person.shares_with(@current_user)
  end
end
