# frozen_string_literal: true

class PhotoService
  def initialize(user=nil, deny_raw_files=true)
    @user = user
    @deny_raw_files = deny_raw_files
  end

  def visible_photo(photo_guid)
    Photo.owned_or_visible_by_user(@user).where(guid: photo_guid).first
  end

  def create_from_params_and_file(base_params, uploaded_file)
    photo_params = build_params(base_params)

    raise RuntimeError if @deny_raw_files && !confirm_uploaded_file_settings(uploaded_file)
    photo_params[:user_file] = uploaded_file

    @photo = @user.build_post(:photo, photo_params)
    raise RuntimeError unless @photo.save
    unless @photo.pending
      unless @photo.public?
        aspects = @user.aspects_from_ids(photo_params[:aspect_ids])
        @user.add_to_streams(@photo, aspects)
      end
      @user.dispatch_post(@photo, to: photo_params[:aspect_ids])
    end

    if photo_params[:set_profile_photo]
      profile_params = {image_url:        @photo.url(:thumb_large),
                        image_url_medium: @photo.url(:thumb_medium),
                        image_url_small:  @photo.url(:thumb_small)}
      @user.update_profile(profile_params)
    end

    @photo
  end

  private

  def build_params(base_params)
    photo_params = base_params.permit(:pending, :set_profile_photo, aspect_ids: [])
    if base_params.permit(:aspect_ids)[:aspect_ids] == "all"
      photo_params[:aspect_ids] = @user.aspects.map(&:id)
    elsif photo_params[:aspect_ids].is_a?(Hash)
      photo_params[:aspect_ids] = params[:photo][:aspect_ids].values
    end
    photo_params
  end

  def confirm_uploaded_file_settings(uploaded_file)
    unless uploaded_file.is_a?(ActionDispatch::Http::UploadedFile) || uploaded_file.is_a?(Rack::Test::UploadedFile)
      return false
    end
    return false if uploaded_file.original_filename.empty?
    return false if uploaded_file.content_type.empty?
    true
  end
end
