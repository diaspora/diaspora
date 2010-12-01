require 'term/ansicolor'

# Use this trick to work around namespace cluttering that
# happens if you just include Term::ANSIColor:

class Color
  extend Term::ANSIColor
end

print Color.red, Color.bold, "No Namespace cluttering:", Color.clear, "\n"
print Color.green + "green" + Color.clear, "\n"
print Color.on_red(Color.green("green")), "\n"
print Color.yellow { Color.on_black { "yellow on_black" } }, "\n\n"

# Or shortcut Term::ANSIColor by assignment:
c = Term::ANSIColor

print c.red, c.bold, "No Namespace cluttering (alternative):", c.clear, "\n"
print c.green + "green" + c.clear, "\n"
print c.on_red(c.green("green")), "\n"
print c.yellow { c.on_black { "yellow on_black" } }, "\n\n"

# Anyway, I don't define any of Term::ANSIColor's methods in this example
# and I want to keep it short:
include Term::ANSIColor

print red, bold, "Usage as constants:", reset, "\n"
print clear, "clear", reset, reset, "reset", reset,
  bold, "bold", reset, dark, "dark", reset,
  underscore, "underscore", reset, blink, "blink", reset,
  negative, "negative", reset, concealed, "concealed", reset, "|\n",
  black, "black", reset, red, "red", reset, green, "green", reset,
  yellow, "yellow", reset, blue, "blue", reset, magenta, "magenta", reset,
  cyan, "cyan", reset, white, "white", reset, "|\n",
  on_black, "on_black", reset, on_red, "on_red", reset,
  on_green, "on_green", reset, on_yellow, "on_yellow", reset,
  on_blue, "on_blue", reset, on_magenta, "on_magenta", reset,
  on_cyan, "on_cyan", reset, on_white, "on_white", reset, "|\n\n"

print red, bold, "Usage as unary argument methods:", reset, "\n"
print clear("clear"), reset("reset"), bold("bold"), dark("dark"),
  underscore("underscore"), blink("blink"), negative("negative"),
  concealed("concealed"), "|\n",
  black("black"), red("red"), green("green"), yellow("yellow"),
  blue("blue"), magenta("magenta"), cyan("cyan"), white("white"), "|\n",
  on_black("on_black"), on_red("on_red"), on_green("on_green"),#
  on_yellow("on_yellow"), on_blue("on_blue"), on_magenta("on_magenta"),
  on_cyan("on_cyan"), on_white("on_white"), "|\n\n"

print red { bold { "Usage as block forms:" } }, "\n"
print clear { "clear" }, reset { "reset" }, bold { "bold" },
  dark { "dark" }, underscore { "underscore" }, blink { "blink" },
  negative { "negative" }, concealed { "concealed" }, "|\n",
  black { "black" }, red { "red" }, green { "green" },
  yellow { "yellow" }, blue { "blue" }, magenta { "magenta" },
  cyan { "cyan" }, white { "white" }, "|\n",
  on_black { "on_black" }, on_red { "on_red" }, on_green { "on_green" },
  on_yellow { "on_yellow" }, on_blue { "on_blue" },
  on_magenta { "on_magenta" }, on_cyan { "on_cyan" },
  on_white { "on_white" }, "|\n\n"

# Usage as Mixin into String or its Subclasses
class String
  include Term::ANSIColor
end

print "Usage as String Mixins:".red.bold, "\n"
print "clear".clear, "reset".reset, "bold".bold, "dark".dark,
  "underscore".underscore, "blink".blink, "negative".negative,
  "concealed".concealed, "|\n",
  "black".black, "red".red, "green".green, "yellow".yellow,
  "blue".blue, "magenta".magenta, "cyan".cyan, "white".white, "|\n",
  "on_black".on_black, "on_red".on_red, "on_green".on_green,
  "on_yellow".on_yellow, "on_blue".on_blue, "on_magenta".on_magenta,
  "on_cyan".on_cyan, "on_white".on_white, "|\n\n"

symbols = Term::ANSIColor::attributes
print red { bold { "All supported attributes = " } },
  blue { symbols.inspect }, "\n\n"

print "Send symbols to strings:".send(:red).send(:bold), "\n"
print symbols[12, 8].map { |c| c.to_s.send(c) }, "\n\n"

print red { bold { "Make strings monochromatic again:" } }, "\n"
print [
    "red".red,
    "not red anymore".red.uncolored,
    uncolored { "not red anymore".red },
    uncolored("not red anymore".red)
  ].map { |x| x + "\n" }
