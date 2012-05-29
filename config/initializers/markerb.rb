require Rails.root.join("lib", "diaspora", "markdownify_email")

Rails.application.config.markerb.renderer = Diaspora::Markdownify::Email