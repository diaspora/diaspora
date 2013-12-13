class Backbone::BaseController < ApplicationController

  # backbone private API is JSON only! - with custom 'Accept' header
  respond_to :backbone

  # exception handling
  rescue_from Diaspora::Backbone::BadRequest, with: :halt_400_bad_request
  rescue_from Diaspora::Backbone::NotFound, with: :halt_404_not_found

  protected

  def paginate(relation)
    paginated_rel = relation.paginate(page: current_page, per_page: items_per_page)
    set_pagination_headers(paginated_rel)
    paginated_rel
  end

  def self.responder
    Diaspora::Backbone::Responder
  end

  private

  # @return [Fixnum] current page. default: 1
  def current_page
    page = params[:page].to_i
    page.between?(1, Float::INFINITY) ? page : 1
  end

  # @return [Fixnum] number of items per page.
  #                  default: 15, max: 50
  def items_per_page
    [[15, params[:per_page].presence.to_i].max, 50].min
  end

  # add a recommended "Link" header to the response pointing to the URLs for
  # paginated data sets
  def set_pagination_headers(relation)
    request_url = request.original_url.split("?").first

    links = []
    links << %(<#{request_url}?page=#{relation.previous_page}&per_page=#{items_per_page}>; rel="prev") if relation.previous_page
    links << %(<#{request_url}?page=#{relation.next_page}&per_page=#{items_per_page}>; rel="next") if relation.next_page
    links << %(<#{request_url}?page=1&per_page=#{items_per_page}>; rel="first")
    links << %(<#{request_url}?page=#{relation.total_pages}&per_page=#{items_per_page}>; rel="last")

    response.headers["Link"] = links.join(",")
  end

  # error output in JSON with appropriate status code. includes an optional note
  def json_error_msg(msg, status_code=500, note=nil)
    data = { message: msg }
    data[:notice] = note unless note.nil?
    render json: data, status: status_code
  end

  def halt_400_bad_request(msg=nil)
    json_error_msg("Bad request!", 400, msg)
  end

  def halt_404_not_found
    json_error_msg("Not found!", 404)
  end
end
