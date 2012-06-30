#custom_logger.rb

class ActiveSupport::BufferedLogger
  def formatter=(formatter)
    @log.formatter = formatter
  end
end

class Formatter
  COLORS = {
    'FG' => {
      'black'  => '30',
      'red'    => '31',
      'green'  => '32',
      'yellow' => '33',
      'blue'   => '34',
      'violet' => '35',
      'cyan'   => '36',
      'white'  => '37',
    },
    'BG' => {
      'black'  => '40',
      'red'    => '41',
      'green'  => '42',
      'yellow' => '43',
      'blue'   => '44',
      'violet' => '45',
      'cyan'   => '46',
      'white'  => '47',
    }
  }

  DULL   = '0'
  BRIGHT = '1'
  NULL   = '00'

  ESC   = "\e"
  RESET = "#{ESC}[00;0;00m"
  # example: \033[40;0;37m white text on black background

  SEVERITY_TO_TAG_MAP   = {'DEBUG'=>'meh',   'INFO'=>'fyi',   'WARN'=>'hmm',    'ERROR'=>'wtf', 'FATAL'=>'omg', 'UNKNOWN'=>'???'}
  SEVERITY_TO_COLOR_MAP = {'DEBUG'=>'white', 'INFO'=>'green', 'WARN'=>'yellow', 'ERROR'=>'red', 'FATAL'=>'red', 'UNKNOWN'=>'white'}

  def initialize
    @colors_enabled = true
  end

  def random
    @random ||= COLORS['FG'].keys[3]
  end

  def colors?
    @colors_enabled
  end

  def fg name
    COLORS['FG'][name]
  end

  def bg name
    COLORS['BG'][name]
  end

  def colorize(message, c_fg='white', c_bg='black', strong=0)
    if colors?
      "#{ESC}[#{fg(c_fg)};#{bg(c_bg)};#{strong==0 ? DULL : BRIGHT}m#{message}#{RESET}"
    else
      message
    end
  end

  def call(severity, time, progname, msg)
    fmt_prefix = pretty_prefix(severity, time)
    fmt_msg    = pretty_message(msg)

    "#{fmt_prefix} #{fmt_msg}\n"
  end

  def pretty_prefix(severity, time)
    color = SEVERITY_TO_COLOR_MAP[severity]
    fmt_severity = colorize(sprintf("%-3s","#{SEVERITY_TO_TAG_MAP[severity]}"), color, 'black', 1)
    fmt_time     = colorize(time.strftime("%s.%L"))
    fmt_env      = colorize(Rails.env, random, 'black', 1)

    "#{fmt_env} - #{fmt_time} [#{fmt_severity}] (pid:#{$$})"
  end

  def pretty_message msg
    w = 130
    txt_w = (w - Rails.env.size - 3)

    # get the prefix without colors, just for the length
    @colors_enabled = false
    prefix = pretty_prefix("DEBUG", Time.now).size + 1
    @colors_enabled = true # restore value

    if (msg.size <= (w-prefix))
      msg
    else
      output = msg.strip.scan(/.{1,#{txt_w}}/).flatten.map { |line| sprintf("%#{w}s", sprintf("%-#{txt_w}s", line)) }.join("\n")
      "\n#{output}"
    end
  end

end

class FederationLogger < ActiveSupport::BufferedLogger
end

if Rails.env.match(/integration/)
  puts "using federation logger"
  logfile = File.open(Rails.root.join("log", "federation_logger.log"), 'a')  #create log file
  logfile.sync = true  #automatically flushes data to file
  FEDERATION_LOGGER = FederationLogger.new(logfile)  #constant accessible anywhere
  FEDERATION_LOGGER.formatter = Formatter.new
else
  FEDERATION_LOGGER = Rails.logger
end
