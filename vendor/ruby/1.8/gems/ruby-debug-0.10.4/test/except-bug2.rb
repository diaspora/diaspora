begin
   exit
   sleep 20
rescue SystemExit
   printf("Exception caught\n")
end
puts "You can't debug here"
