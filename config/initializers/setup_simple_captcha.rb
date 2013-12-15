SimpleCaptcha.setup do |sc|
  sc.image_size = AppConfig.settings.captcha.image_size
  sc.length = AppConfig.settings.captcha.length
  sc.image_style = AppConfig.settings.captcha.image_style
  sc.distortion = AppConfig.settings.captcha.distortion
end