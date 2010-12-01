#
# Included by script/server
#
THIN_PORT=3001
SOCKET_PORT=8081

# Choose one mode by uncommenting
export RAILS_ENV='development'
#export RAILS_ENV='production'
#export RAILS_ENV='test'

# See thin -h for possible values.
DEFAULT_THIN_ARGS="-p $THIN_PORT -e $RAILS_ENV"

# Set to 'no' to disable server dry-run at first start
# creating generated files in public/ folder.
#INIT_PUBLIC='no'
