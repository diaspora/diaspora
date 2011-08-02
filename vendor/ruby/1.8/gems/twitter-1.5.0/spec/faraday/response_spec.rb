require 'helper'

describe Faraday::Response do
  before do
    @client = Twitter::Client.new
  end

  {
    400 => Twitter::BadRequest,
    401 => Twitter::Unauthorized,
    403 => Twitter::Forbidden,
    404 => Twitter::NotFound,
    406 => Twitter::NotAcceptable,
    420 => Twitter::EnhanceYourCalm,
    500 => Twitter::InternalServerError,
    502 => Twitter::BadGateway,
    503 => Twitter::ServiceUnavailable,
  }.each do |status, exception|
    if (status >= 500)
      context "when HTTP status is #{status}" do
        before do
          stub_get('statuses/user_timeline.json').
            with(:query => {:screen_name => 'sferik'}).
            to_return(:status => status)
        end

        it "should raise #{exception.name} error" do
          lambda do
            @client.user_timeline('sferik')
          end.should raise_error(exception)
        end
      end
    else
      [nil, "error", "errors"].each do |body|
        context "when HTTP status is #{status} and body is #{body||='nil'}" do
          before do
            body_message = '{"'+body+'":"test"}' unless body.nil?
            stub_get('statuses/user_timeline.json').
              with(:query => {:screen_name => 'sferik'}).
              to_return(:status => status, :body => body_message)
          end

          it "should raise #{exception.name} error" do
            lambda do
              @client.user_timeline('sferik')
            end.should raise_error(exception)
          end
        end
      end
    end
  end
end
