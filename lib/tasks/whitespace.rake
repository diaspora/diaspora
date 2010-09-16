namespace :whitespace do
  desc 'Removes trailing whitespace'
  task :clean do
    sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
  end
end

