class Api::V0::Serializers::User
  attr_accessor :user

  def initialize(user)
    @user = user
    @person = user.person
    @profile = @person.profile
  end

  def as_json(opts={})
    {
      "diaspora_id" => @person.diaspora_handle,
      "first_name" => @profile.first_name,
      "last_name" => @profile.last_name,
      "image_url" => @profile.image_url,
      "searchable" => @profile.searchable
    }
  end
end
