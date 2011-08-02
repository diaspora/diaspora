# @private
def __p(path) File.join(YARD::ROOT, 'yard', *path.split('/')); end

module YARD
  module CLI # Namespace for command-line interface components
    autoload :Command,        __p('cli/command')
    autoload :CommandParser,  __p('cli/command_parser')
    autoload :Config,         __p('cli/config')
    autoload :Diff,           __p('cli/diff')
    autoload :Gems,           __p('cli/gems')
    autoload :Graph,          __p('cli/graph')
    autoload :Help,           __p('cli/help')
    autoload :List,           __p('cli/list')
    autoload :Server,         __p('cli/server')
    autoload :Stats,          __p('cli/stats')
    autoload :Yardoc,         __p('cli/yardoc')
    autoload :YRI,            __p('cli/yri')
  end

  # A "code object" is defined as any entity in the Ruby language.
  # Classes, modules, methods, class variables and constants are the
  # major objects, but DSL languages can create their own by inheriting
  # from {CodeObjects::Base}.
  module CodeObjects
    autoload :Base,                 __p('code_objects/base')
    autoload :CodeObjectList,       __p('code_objects/base')
    autoload :ClassObject,          __p('code_objects/class_object')
    autoload :ClassVariableObject,  __p('code_objects/class_variable_object')
    autoload :ConstantObject,       __p('code_objects/constant_object')
    autoload :ExtendedMethodObject, __p('code_objects/extended_method_object')
    autoload :ExtraFileObject,      __p('code_objects/extra_file_object')
    autoload :MacroObject,          __p('code_objects/macro_object')
    autoload :MethodObject,         __p('code_objects/method_object')
    autoload :ModuleObject,         __p('code_objects/module_object')
    autoload :NamespaceObject,      __p('code_objects/namespace_object')
    autoload :Proxy,                __p('code_objects/proxy')
    autoload :ProxyMethodError,     __p('code_objects/proxy')
    autoload :RootObject,           __p('code_objects/root_object')

    autoload :BUILTIN_ALL,          __p('code_objects/base')
    autoload :BUILTIN_CLASSES,      __p('code_objects/base')
    autoload :BUILTIN_MODULES,      __p('code_objects/base')
    autoload :BUILTIN_EXCEPTIONS,   __p('code_objects/base')
    autoload :CONSTANTMATCH,        __p('code_objects/base')
    autoload :METHODMATCH,          __p('code_objects/base')
    autoload :METHODNAMEMATCH,      __p('code_objects/base')
    autoload :NAMESPACEMATCH,       __p('code_objects/base')
    autoload :NSEP,                 __p('code_objects/base')
    autoload :NSEPQ,                __p('code_objects/base')
    autoload :ISEP,                 __p('code_objects/base')
    autoload :ISEPQ,                __p('code_objects/base')
    autoload :CSEP,                 __p('code_objects/base')
    autoload :CSEPQ,                __p('code_objects/base')
  end

  # Handlers are called during the data processing part of YARD's
  # parsing phase. This allows YARD as well as any custom extension to
  # analyze source and generate {CodeObjects} to be stored for later use.
  module Handlers
    module Ruby # All Ruby handlers
      module Legacy # Handlers for old Ruby 1.8 parser
        autoload :Base,                   __p('handlers/ruby/legacy/base')

        autoload :AliasHandler,           __p('handlers/ruby/legacy/alias_handler')
        autoload :AttributeHandler,       __p('handlers/ruby/legacy/attribute_handler')
        autoload :ClassHandler,           __p('handlers/ruby/legacy/class_handler')
        autoload :ClassConditionHandler,  __p('handlers/ruby/legacy/class_condition_handler')
        autoload :ClassVariableHandler,   __p('handlers/ruby/legacy/class_variable_handler')
        autoload :ConstantHandler,        __p('handlers/ruby/legacy/constant_handler')
        autoload :ExceptionHandler,       __p('handlers/ruby/legacy/exception_handler')
        autoload :ExtendHandler,          __p('handlers/ruby/legacy/extend_handler')
        autoload :MacroHandler,           __p('handlers/ruby/legacy/macro_handler')
        autoload :MethodHandler,          __p('handlers/ruby/legacy/method_handler')
        autoload :MixinHandler,           __p('handlers/ruby/legacy/mixin_handler')
        autoload :ModuleHandler,          __p('handlers/ruby/legacy/module_handler')
        autoload :PrivateConstantHandler, __p('handlers/ruby/legacy/private_constant_handler')
        autoload :VisibilityHandler,      __p('handlers/ruby/legacy/visibility_handler')
        autoload :YieldHandler,           __p('handlers/ruby/legacy/yield_handler')
      end

      autoload :Base,                     __p('handlers/ruby/base')

      autoload :AliasHandler,             __p('handlers/ruby/alias_handler')
      autoload :AttributeHandler,         __p('handlers/ruby/attribute_handler')
      autoload :ClassHandler,             __p('handlers/ruby/class_handler')
      autoload :ClassConditionHandler,    __p('handlers/ruby/class_condition_handler')
      autoload :ClassVariableHandler,     __p('handlers/ruby/class_variable_handler')
      autoload :ConstantHandler,          __p('handlers/ruby/constant_handler')
      autoload :ExceptionHandler,         __p('handlers/ruby/exception_handler')
      autoload :ExtendHandler,            __p('handlers/ruby/extend_handler')
      autoload :MacroHandler,             __p('handlers/ruby/macro_handler')
      autoload :MacroHandlerMethods,      __p('handlers/ruby/macro_handler_methods')
      autoload :MethodHandler,            __p('handlers/ruby/method_handler')
      autoload :MethodConditionHandler,   __p('handlers/ruby/method_condition_handler')
      autoload :MixinHandler,             __p('handlers/ruby/mixin_handler')
      autoload :ModuleHandler,            __p('handlers/ruby/module_handler')
      autoload :PrivateConstantHandler,   __p('handlers/ruby/private_constant_handler')
      autoload :StructHandlerMethods,     __p('handlers/ruby/struct_handler_methods')
      autoload :VisibilityHandler,        __p('handlers/ruby/visibility_handler')
      autoload :YieldHandler,             __p('handlers/ruby/yield_handler')
    end

    autoload :Base,                       __p('handlers/base')
    autoload :NamespaceMissingError,      __p('handlers/base')
    autoload :Processor,                  __p('handlers/processor')
  end

  # The parser namespace holds all parsing engines used by YARD.
  # Currently only Ruby and C (Ruby) parsers are implemented.
  module Parser
    module Ruby # Ruby parsing components.
      module Legacy # Handles Ruby parsing in Ruby 1.8.
        autoload :RipperParser,   __p('parser/ruby/legacy/ruby_parser')
        autoload :RubyParser,     __p('parser/ruby/legacy/ruby_parser')
        autoload :RubyToken,      __p('parser/ruby/legacy/ruby_lex')
        autoload :Statement,      __p('parser/ruby/legacy/statement')
        autoload :StatementList,  __p('parser/ruby/legacy/statement_list')
        autoload :TokenList,      __p('parser/ruby/legacy/token_list')
      end

      autoload :AstNode,           __p('parser/ruby/ast_node')
      autoload :RubyParser,        __p('parser/ruby/ruby_parser')
    end

    autoload :Base,                __p('parser/base')
    autoload :CParser,             __p('parser/c_parser')
    autoload :ParserSyntaxError,   __p('parser/source_parser')
    autoload :SourceParser,        __p('parser/source_parser')
    autoload :UndocumentableError, __p('parser/source_parser')
  end

  module Rake # Holds Rake tasks used by YARD
    autoload :YardocTask, __p('rake/yardoc_task')
  end

  module Serializers # Namespace for components that serialize to various endpoints
    autoload :Base,                 __p('serializers/base')
    autoload :FileSystemSerializer, __p('serializers/file_system_serializer')
    autoload :ProcessSerializer,    __p('serializers/process_serializer')
    autoload :StdoutSerializer,     __p('serializers/stdout_serializer')
    autoload :YardocSerializer,     __p('serializers/yardoc_serializer')
  end

  # Namespace for classes and modules that handle serving documentation over HTTP
  #
  # == Implementing a Custom Server
  # To customize the YARD server, see the {Adapter} and {Router} classes.
  #
  # == Rack Middleware
  # If you want to use the YARD server as a Rack middleware, see the documentation
  # in {RackMiddleware}.
  #
  # @since 0.6.0
  module Server
    require __p('server')

    # Commands implement specific kinds of server responses which are routed
    # to by the {Router} class. To implement a custom command, subclass {Commands::Base}.
    module Commands
      autoload :Base,                 __p('server/commands/base')
      autoload :DisplayFileCommand,   __p('server/commands/display_file_command')
      autoload :DisplayObjectCommand, __p('server/commands/display_object_command')
      autoload :FramesCommand,        __p('server/commands/frames_command')
      autoload :ListCommand,          __p('server/commands/list_command')
      autoload :ListClassesCommand,   __p('server/commands/list_command')
      autoload :ListFilesCommand,     __p('server/commands/list_command')
      autoload :ListMethodsCommand,   __p('server/commands/list_command')
      autoload :LibraryCommand,       __p('server/commands/library_command')
      autoload :LibraryIndexCommand,  __p('server/commands/library_index_command')
      autoload :SearchCommand,        __p('server/commands/search_command')
      autoload :StaticFileCommand,    __p('server/commands/static_file_command')
    end

    autoload :Adapter,                __p('server/adapter')
    autoload :DocServerSerializer,    __p('server/doc_server_serializer')
    autoload :DocServerHelper,        __p('server/doc_server_helper')
    autoload :FinishRequest,          __p('server/adapter')
    autoload :LibraryVersion,         __p('server/library_version')
    autoload :NotFoundError,          __p('server/adapter')
    autoload :RackAdapter,            __p('server/rack_adapter')
    autoload :RackMiddleware,         __p('server/rack_adapter')
    autoload :Router,                 __p('server/router')
    autoload :StaticCaching,          __p('server/static_caching')
    autoload :WebrickAdapter,         __p('server/webrick_adapter')
    autoload :WebrickServlet,         __p('server/webrick_adapter')
  end

  module Tags # Namespace for Tag components
    autoload :DefaultFactory, __p('tags/default_factory')
    autoload :DefaultTag,     __p('tags/default_tag')
    autoload :Library,        __p('tags/library')
    autoload :OptionTag,      __p('tags/option_tag')
    autoload :OverloadTag,    __p('tags/overload_tag')
    autoload :RefTag,         __p('tags/ref_tag')
    autoload :RefTagList,     __p('tags/ref_tag_list')
    autoload :Tag,            __p('tags/tag')
    autoload :TagFormatError, __p('tags/tag_format_error')
  end

  # Namespace for templating system
  module Templates
    module Helpers # Namespace for template helpers
      module Markup # Namespace for markup providers
        autoload :RDocMarkup,               __p('templates/helpers/markup/rdoc_markup')
      end

      autoload :BaseHelper,                 __p('templates/helpers/base_helper')
      autoload :FilterHelper,               __p('templates/helpers/filter_helper')
      autoload :HtmlHelper,                 __p('templates/helpers/html_helper')
      autoload :HtmlSyntaxHighlightHelper,  __p('templates/helpers/html_syntax_highlight_helper')
      autoload :MarkupHelper,               __p('templates/helpers/markup_helper')
      autoload :MethodHelper,               __p('templates/helpers/method_helper')
      autoload :ModuleHelper,               __p('templates/helpers/module_helper')
      autoload :TextHelper,                 __p('templates/helpers/text_helper')
      autoload :UMLHelper,                  __p('templates/helpers/uml_helper')
    end

    autoload :Engine,   __p('templates/engine')
    autoload :ErbCache, __p('templates/erb_cache')
    autoload :Section,  __p('templates/section')
    autoload :Template, __p('templates/template')
  end

  autoload :Config,         __p('config')
  autoload :Docstring,      __p('docstring')
  autoload :Logger,         __p('logging')
  autoload :Registry,       __p('registry')
  autoload :RegistryStore,  __p('registry_store')
  autoload :StubProxy,      __p('serializers/yardoc_serializer')
  autoload :Verifier,       __p('verifier')
end

undef __p
