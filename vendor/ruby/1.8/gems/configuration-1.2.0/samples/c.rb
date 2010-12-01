#
# configuration.rb let's you keep code very dry.
#

  require 'configuration'

  Configuration.load 'c'

  p Configuration.for('development').db
  p Configuration.for('production').db
  p Configuration.for('testing').db
