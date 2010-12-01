require 'cucumber/ast/comment'
require 'cucumber/ast/features'
require 'cucumber/ast/feature'
require 'cucumber/ast/background'
require 'cucumber/ast/scenario'
require 'cucumber/ast/scenario_outline'
require 'cucumber/ast/step_invocation'
require 'cucumber/ast/step_collection'
require 'cucumber/ast/step'
require 'cucumber/ast/table'
require 'cucumber/ast/tags'
require 'cucumber/ast/py_string'
require 'cucumber/ast/outline_table'
require 'cucumber/ast/examples'
require 'cucumber/ast/visitor'
require 'cucumber/ast/tree_walker'

module Cucumber
  # Classes in this module represent the Abstract Syntax Tree (AST)
  # that gets built when feature files are parsed.
  #
  # AST classes don't expose any internal data directly. This is
  # in order to encourage a less coupled design in the classes
  # that operate on the AST. The only public method is #accept.
  #
  # The AST can be traversed with a visitor. See Cucumber::Format::Pretty
  # for an example.
  module Ast
  end
end