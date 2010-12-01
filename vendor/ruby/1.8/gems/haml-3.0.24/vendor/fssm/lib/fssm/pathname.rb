require 'fileutils'
require 'find'

module FSSM
  class Pathname < String
    SYMLOOP_MAX = 8

    ROOT    = '/'.freeze
    DOT     = '.'.freeze
    DOT_DOT = '..'.freeze

    class << self
      def for(path)
        path.is_a?(::FSSM::Pathname) ? path : new("#{path}")
      end
    end

    def initialize(path)
      raise ArgumentError, "path cannot contain ASCII NULLs" if path =~ %r{\0}
      super(path)
    end

    def <=>(other)
      self.tr('/', "\0").to_s <=> other.to_str.tr('/', "\0")
    rescue NoMethodError
      nil
    end

    def ==(other)
      left  =                  self.cleanpath.tr('/', "\0").to_s
      right = self.class.for(other).cleanpath.tr('/', "\0").to_s

      left == right
    rescue NoMethodError
      false
    end

    def +(path)
      dup << path
    end

    def <<(path)
      replace( join(path).cleanpath! )
    end

    def absolute?
      self[0, 1].to_s == ROOT
    end

    def ascend
      parts = to_a
      parts.length.downto(1) do |i|
        yield self.class.join(parts[0, i])
      end
    end

    def children
      entries[2..-1]
    end

    def cleanpath!
      parts = to_a
      final = []

      parts.each do |part|
        case part
          when DOT     then
            next
          when DOT_DOT then
            case final.last
              when ROOT    then
                next
              when DOT_DOT then
                final.push(DOT_DOT)
              when nil     then
                final.push(DOT_DOT)
              else
                final.pop
            end
          else
            final.push(part)
        end
      end

      replace(final.empty? ? DOT : self.class.join(*final))
    end

    def cleanpath
      dup.cleanpath!
    end

    def descend
      parts = to_a
      1.upto(parts.length) { |i| yield self.class.join(parts[0, i]) }
    end

    def dot?
      self == DOT
    end

    def dot_dot?
      self == DOT_DOT
    end

    def each_filename(&blk)
      to_a.each(&blk)
    end

    def mountpoint?
      stat1 = self.lstat
      stat2 = self.parent.lstat

      stat1.dev != stat2.dev || stat1.ino == stat2.ino
    rescue Errno::ENOENT
      false
    end

    def parent
      self + '..'
    end

    def realpath
      path = self

      SYMLOOP_MAX.times do
        link = path.readlink
        link = path.dirname + link if link.relative?
        path = link
      end

      raise Errno::ELOOP, self
    rescue Errno::EINVAL
      path.expand_path
    end

    def relative?
      !absolute?
    end

    def relative_path_from(base)
      base = self.class.for(base)

      raise ArgumentError, 'no relative path between a relative and absolute' if self.absolute? != base.absolute?

      return self if base.dot?
      return self.class.new(DOT) if self == base

      base = base.cleanpath.to_a
      dest = self.cleanpath.to_a

      while !dest.empty? && !base.empty? && dest[0] == base[0]
        base.shift
        dest.shift
      end

      base.shift if base[0] == DOT
      dest.shift if dest[0] == DOT

      raise ArgumentError, "base directory may not contain '#{DOT_DOT}'" if base.include?(DOT_DOT)

      path = base.fill(DOT_DOT) + dest
      path = self.class.join(*path)
      path = self.class.new(DOT) if path.empty?

      path
    end

    def root?
      !!(self =~ %r{^#{ROOT}+$})
    end

    def to_a
      array = to_s.split(File::SEPARATOR)
      array.delete('')
      array.insert(0, ROOT) if absolute?
      array
    end

    alias segments to_a

    def to_path
      self
    end

    def to_s
      "#{self}"
    end

    alias to_str to_s

    def unlink
      Dir.unlink(self)
      true
    rescue Errno::ENOTDIR
      File.unlink(self)
      true
    end
  end

  class Pathname
    def self.[](pattern)
      Dir[pattern].map! {|d| FSSM::Pathname.new(d) }
    end

    def self.pwd
      FSSM::Pathname.new(Dir.pwd)
    end

    def entries
      Dir.entries(self).map! {|e| FSSM::Pathname.new(e) }
    end

    def mkdir(mode = 0777)
      Dir.mkdir(self, mode)
    end

    def opendir(&blk)
      Dir.open(self, &blk)
    end

    def rmdir
      Dir.rmdir(self)
    end

    def self.glob(pattern, flags = 0)
      dirs = Dir.glob(pattern, flags)
      dirs.map! {|path| FSSM::Pathname.new(path) }

      if block_given?
        dirs.each {|dir| yield dir }
        nil
      else
        dirs
      end
    end

    def glob(pattern, flags = 0, &block)
      patterns = [pattern].flatten
      patterns.map! {|p| self.class.glob(self.to_s + p, flags, &block) }
      patterns.flatten
    end

    def chdir
      blk = lambda { yield self } if block_given?
      Dir.chdir(self, &blk)
    end
  end

  class Pathname
    def blockdev?
      FileTest.blockdev?(self)
    end

    def chardev?
      FileTest.chardev?(self)
    end

    def directory?
      FileTest.directory?(self)
    end

    def executable?
      FileTest.executable?(self)
    end

    def executable_real?
      FileTest.executable_real?(self)
    end

    def exists?
      FileTest.exists?(self)
    end

    def file?
      FileTest.file?(self)
    end

    def grpowned?
      FileTest.grpowned?(self)
    end

    def owned?
      FileTest.owned?(self)
    end

    def pipe?
      FileTest.pipe?(self)
    end

    def readable?
      FileTest.readable?(self)
    end

    def readable_real?
      FileTest.readable_real?(self)
    end

    def setgid?
      FileTest.setgit?(self)
    end

    def setuid?
      FileTest.setuid?(self)
    end

    def socket?
      FileTest.socket?(self)
    end

    def sticky?
      FileTest.sticky?(self)
    end

    def symlink?
      FileTest.symlink?(self)
    end

    def world_readable?
      FileTest.world_readable?(self)
    end

    def world_writable?
      FileTest.world_writable?(self)
    end

    def writable?
      FileTest.writable?(self)
    end

    def writable_real?
      FileTest.writable_real?(self)
    end

    def zero?
      FileTest.zero?(self)
    end
  end

  class Pathname
    def atime
      File.atime(self)
    end

    def ctime
      File.ctime(self)
    end

    def ftype
      File.ftype(self)
    end

    def lstat
      File.lstat(self)
    end

    def mtime
      File.mtime(self)
    end

    def stat
      File.stat(self)
    end

    def utime(atime, mtime)
      File.utime(self, atime, mtime)
    end
  end

  class Pathname
    def self.join(*parts)
      last_part = FSSM::Pathname.new(parts.last)
      return last_part if last_part.absolute?
      FSSM::Pathname.new(File.join(*parts.reject {|p| p.empty? }))
    end

    def basename
      self.class.new(File.basename(self))
    end

    def chmod(mode)
      File.chmod(mode, self)
    end

    def chown(owner, group)
      File.chown(owner, group, self)
    end

    def dirname
      self.class.new(File.dirname(self))
    end

    def expand_path(from = nil)
      self.class.new(File.expand_path(self, from))
    end

    def extname
      File.extname(self)
    end

    def fnmatch?(pat, flags = 0)
      File.fnmatch(pat, self, flags)
    end

    def join(*parts)
      self.class.join(self, *parts)
    end

    def lchmod(mode)
      File.lchmod(mode, self)
    end

    def lchown(owner, group)
      File.lchown(owner, group, self)
    end

    def link(to)
      File.link(self, to)
    end

    def open(mode = 'r', perm = nil, &blk)
      File.open(self, mode, perm, &blk)
    end

    def readlink
      self.class.new(File.readlink(self))
    end

    def rename(to)
      File.rename(self, to)
      replace(to)
    end

    def size
      File.size(self)
    end

    def size?
      File.size?(self)
    end

    def split
      File.split(self).map {|part| FSSM::Pathname.new(part) }
    end

    def symlink(to)
      File.symlink(self, to)
    end

    def truncate
      File.truncate(self)
    end
  end

  class Pathname
    def mkpath
      self.class.new(FileUtils.mkpath(self))
    end

    def rmtree
      self.class.new(FileUtils.rmtree(self).first)
    end

    def touch
      self.class.new(FileUtils.touch(self).first)
    end
  end

  class Pathname
    def each_line(sep = $/, &blk)
      IO.foreach(self, sep, &blk)
    end

    def read(len = nil, off = 0)
      IO.read(self, len, off)
    end

    def readlines(sep = $/)
      IO.readlines(self, sep)
    end

    def sysopen(mode = 'r', perm = nil)
      IO.sysopen(self, mode, perm)
    end
  end

  class Pathname
    def find
      Find.find(self) {|path| yield FSSM::Pathname.new(path) }
    end
  end

  class Pathname
    class << self
      alias getwd pwd
    end

    alias absolute expand_path
    alias delete   unlink
    alias exist?   exists?
    alias fnmatch  fnmatch?
  end
end
