namespace :whitespace do
  desc 'Removes trailing whitespace'
  task :cleanup do
    sh %{for f in `find . -type f | grep -v -e '.git/' -e 'public/' -e '.png'`;
          do cat $f | sed 's/[ \t]*$//' > tmp; cp tmp $f; rm tmp; echo -n .;
        done}
  end
  task :retab do
    sh %{for f in `find . -type f | grep -v -e '.git/' -e 'public/' -e '.png'`;
          do cat $f | sed 's/\t/  /g' > tmp; cp tmp $f; rm tmp; echo -n .;
        done}
  end
end
