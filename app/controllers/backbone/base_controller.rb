class Backbone::BaseController < ApplicationController

  # backbone private API is JSON only! - with custom 'Accept' header
  respond_to :backbone

  # exception handling
  rescue_from Diaspora::Backbone::BadRequest, with: :halt_400_bad_request
  rescue_from Diaspora::Backbone::NotFound, with: :halt_404_not_found

  protected

  def paginate(relation)
    @paginated_rel = relation.paginate(page: current_page, per_page: items_per_page)
    set_pagination_headers
    @paginated_rel
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
    max = 50
    if p = params[:per_page].to_i
      if p.between?(1, max)
        p
      elsif p > max
        max
      elsif p < 1
        15
      end
    else
      15
    end
  end

  # add a recommended "Link" header to the response pointing to the URLs for
  # paginated data sets
  def set_pagination_headers
    request_url = request.original_url.split("?")[0]

    links = []
    links << %(<#{request_url}?page=#{@paginated_rel.previous_page.to_s}&per_page=#{items_per_page}>; rel="prev") if @paginated_rel.previous_page
    links << %(<#{request_url}?page=#{@paginated_rel.next_page.to_s}&per_page=#{items_per_page}>; rel="next") if @paginated_rel.next_page
    links << %(<#{request_url}?page=1&per_page=#{items_per_page}>; rel="first")
    links << %(<#{request_url}?page=#{@paginated_rel.total_pages.to_s}&per_page=#{items_per_page}>; rel="last")

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
