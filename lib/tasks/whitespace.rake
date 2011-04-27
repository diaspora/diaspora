namespace :whitespace do
  desc 'Removes trailing whitespace'
  task :cleanup do
    sh %{for f in `find . -type f | grep -v -e '.git/' -e 'public/' -e '.png'`;
          do cat $f | sed 's/[ \t]*$//' > tmpfile; cp tmpfile $f; rm tmpfile; echo -n .;
        done}
  end
  desc 'Converts hard-tabs into two-space soft-tabs'
  task :retab do
    sh %{for f in `find . -type f | grep -v -e '.git/' -e 'public/' -e '.png'`;
          do cat $f | sed 's/\t/  /g' > tmpfile; cp tmpfile $f; rm tmpfile; echo -n .;
        done}
  end
  desc 'Remove consecutive blank lines'
  task :scrub_gratuitous_newlines do
    sh %{for f in `find . -type f | grep -v -e '.git/' -e 'public/' -e '.png'`;
          do cat $f | sed '/./,/^$/!d' > tmpfile; cp tmpfile $f; rm tmpfile; echo -n .;
        done}
  end
end
