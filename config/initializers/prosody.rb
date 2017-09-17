# frozen_string_literal: true

if AppConfig.chat.enabled? && AppConfig.chat.server.enabled?
  db = Rails.application.config
    .database_configuration[Rails.env]

  Prosody.update_configuration(
    bosh_port: AppConfig.chat.server.bosh.port, bosh_path: AppConfig.chat.server.bosh.bind,
    bosh_interface: AppConfig.chat.server.bosh.address,

    log_debug: (AppConfig.chat.server.log.debug? ? "debug" : "info"),
    log_info: "#{Dir.pwd}/#{AppConfig.chat.server.log.info}",
    log_error: "#{Dir.pwd}/#{AppConfig.chat.server.log.error}",

    certs: "#{Dir.pwd}/#{AppConfig.chat.server.certs}",
    hostname: AppConfig.environment.url,

    virtualhost_driver: db["adapter"],
    virtualhost_database: db["database"],
    virtualhost_username: db["username"],
    virtualhost_password: db["password"],
    virtualhost_host: db["host"]
  )
end
