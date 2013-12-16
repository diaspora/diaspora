SimpleCaptcha.setup do |sc|
  sc.image_size = AppConfig.settings.captcha.image_size
  sc.length = AppConfig.settings.captcha.captcha_length.to_i
  sc.image_style = AppConfig.settings.captcha.image_style
  sc.distortion = AppConfig.settings.captcha.distortion
  p AppConfig.settings.captcha
end