guard 'shell' do
  watch(/source\/sass\/(.*)\.s[ac]ss/) {|m| `compass compile` }
  watch(%r{public/.+\.(js|html)}) {|m| `compass compile` }
end

guard 'livereload', :api_version => '1.6' do
  watch(%r{public/.+\.(css)})
  watch(%r{public/.+\.(js|html)})
end
