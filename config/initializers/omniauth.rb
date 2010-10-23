#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, SERVICES['twitter']['consumer_key'], SERVICES['twitter']['consumer_secret']
  #provider :facebook, 'APP_ID', 'APP_SECRET'  
end  

