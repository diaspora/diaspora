SimpleCaptcha.setup do |sc|
  sc.image_size = AppConfig.settings.captcha.image_size
  value_length = AppConfig.settings.captcha.captcha_length.to_i
  if value_length <= 12 && value_length > 0 
    sc.length = value_length
  else
    sc.length = 5
  end
  sc.image_style = AppConfig.settings.captcha.image_style
  sc.distortion = AppConfig.settings.captcha.distortion
  p AppConfig.settings.captcha
end
