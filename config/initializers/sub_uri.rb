
p = AppConfig[ :pod_uri].path
if p and not p.empty? and p != "/"
    Rails.application.routes.default_url_options = { :script_name => p }
else
    p = nil
end

