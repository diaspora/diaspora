module Excon

  module Errors
    class Error < StandardError
      attr_reader :request, :response

      def initialize(msg, request = nil, response = nil)
        super(msg)
        @request = request
        @response = response
      end
    end

    class Continue < Error; end                     # 100
    class SwitchingProtocols < Error; end           # 101
    class OK < Error; end                           # 200
    class Created < Error; end                      # 201
    class Accepted < Error; end                     # 202
    class NonAuthoritativeInformation < Error; end  # 203
    class NoContent < Error; end                    # 204
    class ResetContent < Error; end                 # 205
    class PartialContent < Error; end               # 206
    class MultipleChoices < Error; end              # 300
    class MovedPermanently < Error; end             # 301
    class Found < Error; end                        # 302
    class SeeOther < Error; end                     # 303
    class NotModified < Error; end                  # 304
    class UseProxy < Error; end                     # 305
    class TemporaryRedirect < Error; end            # 307
    class BadRequest < Error; end                   # 400
    class Unauthorized < Error; end                 # 401
    class PaymentRequired < Error; end              # 402
    class Forbidden < Error; end                    # 403
    class NotFound < Error; end                     # 404
    class MethodNotAllowed < Error; end             # 405
    class NotAcceptable < Error; end                # 406
    class ProxyAuthenticationRequired < Error; end  # 407
    class RequestTimeout < Error; end               # 408
    class Conflict < Error; end                     # 409
    class Gone < Error; end                         # 410
    class LengthRequired < Error; end               # 411
    class PreconditionFailed < Error; end           # 412
    class RequestEntityTooLarge < Error; end        # 412
    class RequestURITooLong < Error; end            # 414
    class UnsupportedMediaType < Error; end         # 415
    class RequestedRangeNotSatisfiable < Error; end # 416
    class ExpectationFailed < Error; end            # 417
    class UnprocessableEntity < Error; end          # 422
    class InternalServerError < Error; end          # 500
    class NotImplemented < Error; end               # 501
    class BadGateway < Error; end                   # 502
    class ServiceUnavailable < Error; end           # 503
    class GatewayTimeout < Error; end               # 504

    # Messages for nicer exceptions, from rfc2616
    def self.status_error(request, response)
      @errors ||= { 
        100 => [Excon::Errors::Continue, 'Continue'],
        101 => [Excon::Errors::SwitchingProtocols, 'Switching Protocols'],
        200 => [Excon::Errors::OK, 'OK'],
        201 => [Excon::Errors::Created, 'Created'],
        202 => [Excon::Errors::Accepted, 'Accepted'],
        203 => [Excon::Errors::NonAuthoritativeInformation, 'Non-Authoritative Information'],
        204 => [Excon::Errors::NoContent, 'No Content'],
        205 => [Excon::Errors::ResetContent, 'Reset Content'],
        206 => [Excon::Errors::PartialContent, 'Partial Content'],
        300 => [Excon::Errors::MultipleChoices, 'Multiple Choices'],
        301 => [Excon::Errors::MovedPermanently, 'Moved Permanently'],
        302 => [Excon::Errors::Found, 'Found'],
        303 => [Excon::Errors::SeeOther, 'See Other'],
        304 => [Excon::Errors::NotModified, 'Not Modified'],
        305 => [Excon::Errors::UseProxy, 'Use Proxy'],
        307 => [Excon::Errors::TemporaryRedirect, 'Temporary Redirect'],
        400 => [Excon::Errors::BadRequest, 'Bad Request'],
        401 => [Excon::Errors::Unauthorized, 'Unauthorized'],
        402 => [Excon::Errors::PaymentRequired, 'Payment Required'],
        403 => [Excon::Errors::Forbidden, 'Forbidden'],
        404 => [Excon::Errors::NotFound, 'Not Found'],
        405 => [Excon::Errors::MethodNotAllowed, 'Method Not Allowed'],
        406 => [Excon::Errors::NotAcceptable, 'Not Acceptable'],
        407 => [Excon::Errors::ProxyAuthenticationRequired, 'Proxy Authentication Required'],
        408 => [Excon::Errors::RequestTimeout, 'Request Timeout'],
        409 => [Excon::Errors::Conflict, 'Conflict'],
        410 => [Excon::Errors::Gone, 'Gone'],
        411 => [Excon::Errors::LengthRequired, 'Length Required'],
        412 => [Excon::Errors::PreconditionFailed, 'Precondition Failed'],
        413 => [Excon::Errors::RequestEntityTooLarge, 'Request Entity Too Large'],
        414 => [Excon::Errors::RequestURITooLong, 'Request-URI Too Long'],
        415 => [Excon::Errors::UnsupportedMediaType, 'Unsupported Media Type'],
        416 => [Excon::Errors::RequestedRangeNotSatisfiable, 'Request Range Not Satisfiable'],
        417 => [Excon::Errors::ExpectationFailed, 'Expectation Failed'],
        422 => [Excon::Errors::UnprocessableEntity, 'Unprocessable Entity'],
        500 => [Excon::Errors::InternalServerError, 'InternalServerError'],
        501 => [Excon::Errors::NotImplemented, 'Not Implemented'],
        502 => [Excon::Errors::BadGateway, 'Bad Gateway'],
        503 => [Excon::Errors::ServiceUnavailable, 'Service Unavailable'],
        504 => [Excon::Errors::GatewayTimeout, 'Gateway Timeout']
      }
      error, message = @errors[response.status] || [Excon::Errors::Error, 'Unknown']
      error.new("Expected(#{request[:expects].inspect}) <=> Actual(#{response.status} #{message})\n  request => #{request.inspect}\n  response => #{response.inspect}", request, response)
    end

  end
end
