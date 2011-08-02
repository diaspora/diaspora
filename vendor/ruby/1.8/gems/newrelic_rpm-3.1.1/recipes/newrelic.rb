# The capistrano recipes in plugins are automatically
# loaded from here.  From gems, they are available from
# the lib directory.  We have to make them available from
# both locations

require File.join(File.dirname(__FILE__),'..','lib','new_relic','recipes')
