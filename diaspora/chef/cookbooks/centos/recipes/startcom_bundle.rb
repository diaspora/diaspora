cookbook_file '/etc/pki/tls/certs/startcom-cert.crt' do
  source 'startcom-bundle.crt'
end

execute 'back up cert bundle' do
  command 'mv /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt.bak'
end

execute 'add startcom cert' do
  command 'cat /etc/pki/tls/certs/ca-bundle.crt.bak /etc/pki/tls/certs/startcom-cert.crt > /etc/pki/tls/certs/ca-bundle.crt'
  not_if "cat /etc/pki/tls/certs/ca-bundle.crt | grep '#{<<LINE_FROM_CERT
J/eUsTc9t8eR9+IB7P2UieHMbtM21goZea7XNIJl/3xCu7bdC6Y0r0tg/n9DSQaL
jEO4VvLZfyFDF+qnSJUBdXXqK6VDleoVhJ0IjSZuVZur3NI50jEdYOKszFZFJPUc
VKvuht2WMoX4TE/olXa2Bd02I2e8/xXiyjvmpuw77CYRNEiN9oArGiMC64ocOnYq
e1YWHHIqs6rjYKUAnwSb4m8eFFhbpWyLWDzDuk46XPfhlis+7we8pOVdzE2fDeHc
qrvhbhrsj+G2TE15cl0XNQsd18FH2pYk4NByqFpfZi0Q3C8qE64m/gocGczQPguc
LINE_FROM_CERT
  }'"
end
