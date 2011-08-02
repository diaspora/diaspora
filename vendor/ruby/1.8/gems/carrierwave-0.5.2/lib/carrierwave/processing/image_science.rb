# encoding: utf-8

require 'image_science'

module CarrierWave
  module ImageScience
    extend ActiveSupport::Concern

    module ClassMethods
      def resize_to_limit(width, height)
        process :resize_to_limit => [width, height]
      end

      def resize_to_fit(width, height)
        process :resize_to_fit => [width, height]
      end

      def resize_to_fill(width, height)
        process :resize_to_fill => [width, height]
      end
    end

    ##
    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio. The image may be shorter or narrower than
    # specified in the smaller dimension but will not be larger than the
    # specified values.
    #
    # See even http://www.imagemagick.org/RMagick/doc/image3.html#resize_to_fit
    #
    # === Parameters
    #
    # [width (Integer)] the width to scale the image to
    # [height (Integer)] the height to scale the image to
    #
    def resize_to_fit(new_width, new_height)
      ::ImageScience.with_image(self.current_path) do |img|
        width, height = extract_dimensions(img.width, img.height, new_width, new_height)
        img.resize( width, height ) do |file|
          file.save( self.current_path )
        end
      end
    end

    ##
    # Resize the image to fit within the specified dimensions while retaining
    # the aspect ratio of the original image. If necessary, crop the image in
    # the larger dimension.
    #
    # See even http://www.imagemagick.org/RMagick/doc/image3.html#resize_to_fill
    #
    # === Parameters
    #
    # [width (Integer)] the width to scale the image to
    # [height (Integer)] the height to scale the image to
    #
    def resize_to_fill(new_width, new_height)
      ::ImageScience.with_image(self.current_path) do |img|
        width, height = extract_dimensions_for_crop(img.width, img.height, new_width, new_height)
        x_offset, y_offset = extract_placement_for_crop(width, height, new_width, new_height)

        # check if if new dimensions are too small for the new image
        if width < new_width
          width = new_width
          height = (new_width.to_f*(img.height.to_f/img.width.to_f)).round
        elsif height < new_height
          height = new_height
          width = (new_height.to_f*(img.width.to_f/img.height.to_f)).round
        end

        img.resize( width, height ) do |i2|

          # check to make sure offset is not negative
          if x_offset < 0
            x_offset = 0
          end
          if y_offset < 0
            y_offset = 0
          end

          i2.with_crop( x_offset, y_offset, new_width + x_offset, new_height + y_offset) do |file|
            file.save( self.current_path )
          end
        end
      end
    end

    ##
    # Resize the image to fit within the specified dimensions while retaining
    # the original aspect ratio. Will only resize the image if it is larger than the
    # specified dimensions. The resulting image may be shorter or narrower than specified
    # in the smaller dimension but will not be larger than the specified values.
    #
    # === Parameters
    #
    # [width (Integer)] the width to scale the image to
    # [height (Integer)] the height to scale the image to
    #
    def resize_to_limit(new_width, new_height)
      ::ImageScience.with_image(self.current_path) do |img|
        if img.width > new_width or img.height > new_height
          resize_to_fit(new_width, new_height)
        end
      end
    end

  private

    def extract_dimensions(width, height, new_width, new_height, type = :resize)
      aspect_ratio = width.to_f / height.to_f
      new_aspect_ratio = new_width / new_height

      if (new_aspect_ratio > aspect_ratio) ^ ( type == :crop )  # Image is too wide, the caret is the XOR operator
        new_width, new_height = [ (new_height * aspect_ratio), new_height]
      else #Image is too narrow
        new_width, new_height = [ new_width, (new_width / aspect_ratio)]
      end

      [new_width, new_height].collect! { |v| v.round }
    end

    def extract_dimensions_for_crop(width, height, new_width, new_height)
      extract_dimensions(width, height, new_width, new_height, :crop)
    end

    def extract_placement_for_crop(width, height, new_width, new_height)
      x_offset = (width / 2.0) - (new_width / 2.0)
      y_offset = (height / 2.0) - (new_height / 2.0)
      [x_offset, y_offset].collect! { |v| v.round }
    end

  end # ImageScience
end # CarrierWave
