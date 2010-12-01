require 'fileutils'

class Terminal
  attr_reader :output, :status

  def initialize
    @cwd = FileUtils.pwd
    @output = ""
    @status = 0
    @logger = Logger.new(File.join(TEMP_ROOT, 'terminal.log'))
  end

  def cd(directory)
    @cwd = directory
  end

  def run(command)
    output << "#{command}\n"
    FileUtils.cd(@cwd) do
      logger.debug(command)
      result = `#{command} 2>&1`
      logger.debug(result)
      output << result
    end
    @status = $?
  end

  def echo(string)
    logger.debug(string)
  end

  private

  attr_reader :logger
end

