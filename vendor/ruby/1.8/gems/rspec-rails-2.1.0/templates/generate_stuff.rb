generate('rspec:install')
generate('controller wombats index') # plural
generate('controller welcome index') # singular
generate('integration_test widgets')
generate('mailer Notifications signup')
generate('model thing name:string')
generate('helper things')
generate('scaffold widget name:string category:string instock:boolean')
generate('observer widget')
generate('scaffold gadget ') # scaffold with no attributes

run('rake db:migrate')
run('rake db:test:prepare')
