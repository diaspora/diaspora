#
# Included by script/server
#

# Choose one mode by uncommenting
export RAILS_ENV='development'
#export RAILS_ENV='production'
#export RAILS_ENV='test'

# See thin -h for possible values. script/server sets -p <port>.
DEFAULT_THIN_ARGS="-e $RAILS_ENV"

# Set to 'no' to disable server dry-run at first start
# creating generated files in public/ folder.
#INIT_PUBLIC='no'
