generate('rspec:install')
generate('controller wombats index') # plural
generate('controller welcome index') # singular
generate('integration_test widgets')
generate('mailer Notifications signup')
generate('model thing name:string')
generate('helper things')
generate('scaffold widget name:string category:string instock:boolean --force')
generate('observer widget')
generate('scaffold gadget') # scaffold with no attributes
generate('scaffold admin/accounts name:string') # scaffold with nested resource

generate('controller things custom_action')
template_code= <<-TEMPLATE
  <% raise 'Error from custom_action because we should never render this template....derp derp derp' %>
TEMPLATE

file "app/views/things/custom_action.html.erb", template_code, {:force=>true}

run('rake db:migrate')
run('rake db:test:prepare')
