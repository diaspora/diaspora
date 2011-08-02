require 'extlib/try_dup'

# Copyright (c) 2004-2008 David Heinemeier Hansson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Allows attributes to be shared within an inheritance hierarchy, but where
# each descendant gets a copy of their parents' attributes, instead of just a
# pointer to the same. This means that the child can add elements to, for
# example, an array without those additions being shared with either their
# parent, siblings, or children, which is unlike the regular class-level
# attributes that are shared across the entire hierarchy.
class Class
  # Defines class-level and instance-level attribute reader.
  #
  # @param [*syms<Array] Array of attributes to define reader for.
  # @return [Array<#to_s>] List of attributes that were made into cattr_readers
  #
  # @api public
  #
  # @todo Is this inconsistent in that it does not allow you to prevent
  #   an instance_reader via :instance_reader => false
  def cattr_reader(*syms)
    syms.flatten.each do |sym|
      next if sym.is_a?(Hash)
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}
          @@#{sym}
        end

        def #{sym}
          @@#{sym}
        end
      RUBY
    end
  end

  # Defines class-level (and optionally instance-level) attribute writer.
  #
  # @param [Array<*#to_s, Hash{:instance_writer => Boolean}>] Array of attributes to define writer for.
  # @option syms :instance_writer<Boolean> if true, instance-level attribute writer is defined.
  # @return [Array<#to_s>] List of attributes that were made into cattr_writers
  #
  # @api public
  def cattr_writer(*syms)
    options = syms.last.is_a?(Hash) ? syms.pop : {}
    syms.flatten.each do |sym|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}=(obj)
          @@#{sym} = obj
        end
      RUBY

      unless options[:instance_writer] == false
        class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{sym}=(obj)
            @@#{sym} = obj
          end
        RUBY
      end
    end
  end

  # Defines class-level (and optionally instance-level) attribute accessor.
  #
  # @param *syms<Array[*#to_s, Hash{:instance_writer => Boolean}]> Array of attributes to define accessor for.
  # @option syms :instance_writer<Boolean> if true, instance-level attribute writer is defined.
  # @return [Array<#to_s>] List of attributes that were made into accessors
  #
  # @api public
  def cattr_accessor(*syms)
    cattr_reader(*syms)
    cattr_writer(*syms)
  end

  # Defines class-level inheritable attribute reader. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[#to_s]> Array of attributes to define inheritable reader for.
  # @return [Array<#to_s>] Array of attributes converted into inheritable_readers.
  #
  # @api public
  #
  # @todo Do we want to block instance_reader via :instance_reader => false
  # @todo It would be preferable that we do something with a Hash passed in
  #   (error out or do the same as other methods above) instead of silently
  #   moving on). In particular, this makes the return value of this function
  #   less useful.
  def class_inheritable_reader(*ivars)
    instance_reader = ivars.pop[:reader] if ivars.last.is_a?(Hash)

    ivars.each do |ivar|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{ivar}
          return @#{ivar} if defined?(@#{ivar})
          return nil      if self.object_id == #{self.object_id}
          ivar = superclass.#{ivar}
          return nil if ivar.nil?
          @#{ivar} = ivar.try_dup
        end
      RUBY

      unless instance_reader == false
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{ivar}
            self.class.#{ivar}
          end
        RUBY
      end
    end
  end

  # Defines class-level inheritable attribute writer. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[*#to_s, Hash{:instance_writer => Boolean}]> Array of attributes to
  #   define inheritable writer for.
  # @option syms :instance_writer<Boolean> if true, instance-level inheritable attribute writer is defined.
  # @return [Array<#to_s>] An Array of the attributes that were made into inheritable writers.
  #
  # @api public
  #
  # @todo We need a style for class_eval <<-HEREDOC. I'd like to make it
  #   class_eval(<<-RUBY, __FILE__, __LINE__), but we should codify it somewhere.
  def class_inheritable_writer(*ivars)
    instance_writer = ivars.pop[:instance_writer] if ivars.last.is_a?(Hash)
    ivars.each do |ivar|
      self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{ivar}=(obj)
          @#{ivar} = obj
        end
      RUBY
      unless instance_writer == false
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{ivar}=(obj) self.class.#{ivar} = obj end
        RUBY
      end
    end
  end

  # Defines class-level inheritable attribute accessor. Attributes are available to subclasses,
  # each subclass has a copy of parent's attribute.
  #
  # @param *syms<Array[*#to_s, Hash{:instance_writer => Boolean}]> Array of attributes to
  #   define inheritable accessor for.
  # @option syms :instance_writer<Boolean> if true, instance-level inheritable attribute writer is defined.
  # @return [Array<#to_s>] An Array of attributes turned into inheritable accessors.
  #
  # @api public
  def class_inheritable_accessor(*syms)
    class_inheritable_reader(*syms)
    class_inheritable_writer(*syms)
  end
end
