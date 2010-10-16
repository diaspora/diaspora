#
# Included by script/server
#
THIN_PORT=3000
SOCKET_PORT=8080

# See thin -h for possible values.
DEFAULT_THIN_ARGS="-p $THIN_PORT"

# Uncomment to run in production mode.
#export RAILS_ENV="production rails server"
