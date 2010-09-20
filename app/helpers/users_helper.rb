module UsersHelper
  # If an array is passed, it's assumed to be a params array.
  # If a string is passed, it's assumed to be the image_url itself.
  def prep_image_url(params)
    if params.is_a? String
      "http://" + request.host + ":" + request.port.to_s + params
    else
      if params[:profile][:image_url].empty?
        params[:profile].delete(:image_url)
      else
        params[:profile][:image_url] = "http://" + request.host + ":" + request.port.to_s + params[:profile][:image_url]
      end
    end
  end
end