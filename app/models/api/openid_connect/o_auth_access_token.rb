# frozen_string_literal: true

# Copyright (c) 2011 nov matake
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# See https://github.com/nov/openid_connect_sample/blob/master/app/models/access_token.rb

module Api
  module OpenidConnect
    class OAuthAccessToken < ApplicationRecord
      belongs_to :authorization

      before_validation :setup, on: :create

      validates :token, presence: true, uniqueness: true

      scope :valid, ->(time) { where("expires_at >= ?", time) }

      def setup
        self.token = SecureRandom.hex(32)
        self.expires_at = 24.hours.from_now
      end

      def bearer_token
        @bearer_token ||= Rack::OAuth2::AccessToken::Bearer.new(
          access_token: token,
          expires_in:   (expires_at - Time.zone.now.utc).to_i
        )
      end
    end
  end
end
