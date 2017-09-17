# frozen_string_literal: true

SimpleCaptcha.setup do |sc|
  sc.image_size = AppConfig.settings.captcha.image_size
  sc.length = [1, [AppConfig.settings.captcha.captcha_length.to_i, 12].min].max
  sc.image_style = AppConfig.settings.captcha.image_style
  sc.distortion = AppConfig.settings.captcha.distortion
end
