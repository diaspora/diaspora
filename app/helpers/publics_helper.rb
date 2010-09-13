#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


module PublicsHelper
  def subscribe(opts = {})
    subscriber = Subscriber.first(:url => opts[:callback], :topic => opts[:topic])
    subscriber ||= Subscriber.new(:url => opts[:callback], :topic => opts[:topic])

    if subscriber.save

      if opts[:verify] == 'sync'
        204
      elsif opts[:verify] == 'async'
        202
      end
    else 
      400
    end
  end

  def terse_url(full_url)
    terse = full_url.gsub(/https?:\/\//, '')
    terse.gsub!(/www\./, '')
    terse = terse.chop! if terse[-1, 1] == '/'
    terse
  end
end
