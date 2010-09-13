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


class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/images"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    model.id.to_s + File.extname(@filename) if @filename
  end

  version :thumb_small do
    process :resize_to_fill => [50,50]
  end

  version :thumb_medium do
    process :resize_to_fill => [100,100]
  end

  version :thumb_large do
    process :resize_to_fill => [200,200]
  end

  version :scaled_full do
    process :resize_to_limit => [700,700]
  end
end
