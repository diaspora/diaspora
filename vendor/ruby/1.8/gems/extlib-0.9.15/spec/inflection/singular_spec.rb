require 'spec_helper'
require 'extlib/inflection'

describe Extlib::Inflection, "#singular" do
  # ==== exceptional cases

  it "singularizes equipment => equipment" do
    "equipment".singular.should == "equipment"
  end

  it "singularizes postgres => postgres" do
    "postgres".singular.should == "postgres"
  end

  it "singularizes mysql => mysql" do
    "mysql".singular.should == "mysql"
  end

  it "singularizes information => information" do
    "information".singular.should == "information"
  end

  it "singularizes money => money" do
    "money".singular.should == "money"
  end

  it "singularizes species => species" do
    "species".singular.should == "species"
  end

  it "singularizes series => series" do
    "series".singular.should == "series"
  end

  it "singularizes fish => fish" do
    "fish".singular.should == "fish"
  end

  it "singularizes sheep => sheep" do
    "sheep".singular.should == "sheep"
  end

  it "singularizes news => news" do
    "news".singular.should == "news"
  end

  it "singularizes rain => rain" do
    "rain".singular.should == "rain"
  end

  it "singularizes milk => milk" do
    "milk".singular.should == "milk"
  end

  it "singularizes moose => moose" do
    "moose".singular.should == "moose"
  end

  it "singularizes hovercraft => hovercraft" do
    "hovercraft".singular.should == "hovercraft"
  end

  it "singularizes cactus => cacti" do
    "cacti".singular.should == "cactus"
  end

  it "singularizes thesauri => thesaurus" do
    "thesauri".singular.should == "thesaurus"
  end

  it "singularizes matrices => matrix" do
    "matrices".singular.should == "matrix"
  end

  it "singularizes Swiss => Swiss" do
    "Swiss".singular.should == "Swiss"
  end

  it "singularizes lives => life" do
    "lives".singular.should == "life"
  end

  it "singularizes wives => wife" do
    "wives".singular.should == "wife"
  end

  it "singularizes geese => goose" do
    "geese".singular.should == "goose"
  end

  it "singularizes criteria => criterion" do
    "criteria".singular.should == "criterion"
  end

  it "singularizes aliases => alias" do
    "aliases".singular.should == "alias"
  end

  it "singularizes statuses => status" do
    "statuses".singular.should == "status"
  end

  it "singularizes axes => axis" do
    "axes".singular.should == "axis"
  end

  it "singularizes crises => crisis" do
    "crises".singular.should == "crisis"
  end

  it "singularizes testes => testis" do
    "testes".singular.should == "testis"
  end

  it "singularizes children => child" do
    "children".singular.should == "child"
  end

  it "singularizes people => person" do
    "people".singular.should == "person"
  end

  it "singularizes potatoes => potato" do
    "potatoes".singular.should == "potato"
  end

  it "singularizes tomatoes => tomato" do
    "tomatoes".singular.should == "tomato"
  end

  it "singularizes buffaloes => buffalo" do
    "buffaloes".singular.should == "buffalo"
  end

  it "singularizes torpedoes => torpedo" do
    "torpedoes".singular.should == "torpedo"
  end

  it "singularizes quizzes => quiz" do
    "quizzes".singular.should == "quiz"
  end

  # used to be a bug exposed by this specs suite,
  # this MUST pass or we've got regression
  it "singularizes vertices => vertex" do
    "vertices".singular.should == "vertex"
  end

  it "singularizes indices => index" do
    "indices".singular.should == "index"
  end

  it "singularizes oxen => ox" do
    "oxen".singular.should == "ox"
  end

  it "singularizes mice => mouse" do
    "mice".singular.should == "mouse"
  end

  it "singularizes lice => louse" do
    "lice".singular.should == "louse"
  end

  it "singularizes theses => thesis" do
    "theses".singular.should == "thesis"
  end

  it "singularizes thieves => thief" do
    "thieves".singular.should == "thief"
  end

  it "singularizes analyses => analysis" do
    "analyses".singular.should == "analysis"
  end

  it "singularizes octopi => octopus" do
    "octopi".singular.should == "octopus"
  end

  it "singularizes grass => grass" do
    "grass".singular.should == "grass"
  end

  it "singularizes phenomena => phenomenon" do
    "phenomena".singular.should == "phenomenon"
  end





  # ==== bugs, typos and reported issues





  # ==== rules

  it "singularizes forums => forum" do
    "forums".singular.should == "forum"
  end

  it "singularizes hives => hive" do
    "hives".singular.should == "hive"
  end

  it "singularizes athletes => athlete" do
    "athletes".singular.should == "athlete"
  end

  it "singularizes dwarves => dwarf" do
    "dwarves".singular.should == "dwarf"
  end

  it "singularizes heroes => hero" do
    "heroes".singular.should == "hero"
  end

  it "singularizes zeroes => zero" do
    "zeroes".singular.should == "zero"
  end

  it "singularizes men => man" do
    "men".singular.should == "man"
  end

  it "singularizes women => woman" do
    "women".singular.should == "woman"
  end

  it "singularizes sportsmen => sportsman" do
    "sportsmen".singular.should == "sportsman"
  end

  it "singularizes branches => branch" do
    "branches".singular.should == "branch"
  end

  it "singularizes crunches => crunch" do
    "crunches".singular.should == "crunch"
  end

  it "singularizes trashes => trash" do
    "trashes".singular.should == "trash"
  end

  it "singularizes mashes => mash" do
    "mashes".singular.should == "mash"
  end

  it "singularizes crosses => cross" do
    "crosses".singular.should == "cross"
  end

  it "singularizes errata => erratum" do
    "errata".singular.should == "erratum"
  end

  # FIXME: add -ia => -ium cases

  # FIXME: add -ra => -rum cases

  it "singularizes rays => ray" do
    "rays".singular.should == "ray"
  end

  it "singularizes sprays => spray" do
    "sprays".singular.should == "spray"
  end

  # Merriam-Webster dictionary says
  # preys is correct, too.
  it "singularizes preys => prey" do
    "preys".singular.should == "prey"
  end

  it "singularizes toys => toy" do
    "toys".singular.should == "toy"
  end

  it "singularizes joys => joy" do
    "joys".singular.should == "joy"
  end

  it "singularizes buys => buy" do
    "buys".singular.should == "buy"
  end

  it "singularizes guys => guy" do
    "guys".singular.should == "guy"
  end

  it "singularizes cries => cry" do
    "cries".singular.should == "cry"
  end

  it "singularizes flies => fly" do
    "flies".singular.should == "fly"
  end

  it "singularizes foxes => fox" do
    "foxes".singular.should == "fox"
  end

  it "singularizes elves => elf" do
    "elves".singular.should == "elf"
  end

  it "singularizes shelves => shelf" do
    "shelves".singular.should == "shelf"
  end

  it "singularizes pluses => plus" do
    "pluses".singular.should == "plus"
  end

  it "singularizes cats => cat" do
    "cats".singular.should == "cat"
  end

  it "singularizes rats => rat" do
    "rats".singular.should == "rat"
  end

  it "singularizes roses => rose" do
    "roses".singular.should == "rose"
  end

  it "singularizes projects => project" do
    "projects".singular.should == "project"
  end

  it "singularizes posts => post" do
    "posts".singular.should == "post"
  end

  it "singularizes articles => article" do
    "articles".singular.should == "article"
  end

  it "singularizes locations => location" do
    "locations".singular.should == "location"
  end

  it "singularizes friends => friend" do
    "friends".singular.should == "friend"
  end

  it "singularizes links => link" do
    "links".singular.should == "link"
  end

  it "singularizes urls => url" do
    "urls".singular.should == "url"
  end

  it "singularizes accounts => account" do
    "accounts".singular.should == "account"
  end

  it "singularizes servers => server" do
    "servers".singular.should == "server"
  end

  it "singularizes fruits => fruit" do
    "fruits".singular.should == "fruit"
  end

  it "singularizes maps => map" do
    "maps".singular.should == "map"
  end

  it "singularizes incomes => income" do
    "incomes".singular.should == "income"
  end

  it "singularizes pings => ping" do
    "pings".singular.should == "ping"
  end

  it "singularizes events => event" do
    "events".singular.should == "event"
  end

  it "singularizes proofs => proof" do
    "proofs".singular.should == "proof"
  end

  it "singularizes typos => typo" do
    "typos".singular.should == "typo"
  end

  it "singularizes attachments => attachment" do
    "attachments".singular.should == "attachment"
  end

  it "singularizes downloads => download" do
    "downloads".singular.should == "download"
  end

  it "singularizes assets => asset" do
    "assets".singular.should == "asset"
  end

  it "singularizes jobs => job" do
    "jobs".singular.should == "job"
  end

  it "singularizes cities => city" do
    "cities".singular.should == "city"
  end

  it "singularizes packages => package" do
    "packages".singular.should == "package"
  end

  it "singularizes commits => commit" do
    "commits".singular.should == "commit"
  end

  it "singularizes versions => version" do
    "versions".singular.should == "version"
  end

  it "singularizes documents => document" do
    "documents".singular.should == "document"
  end

  it "singularizes editions => edition" do
    "editions".singular.should == "edition"
  end

  it "singularizes movies => movie" do
    "movies".singular.should == "movie"
  end

  it "singularizes songs => song" do
    "songs".singular.should == "song"
  end

  it "singularizes invoices => invoice" do
    "invoices".singular.should == "invoice"
  end

  it "singularizes products => product" do
    "products".singular.should == "product"
  end

  it "singularizes books => book" do
    "books".singular.should == "book"
  end

  it "singularizes tickets => ticket" do
    "tickets".singular.should == "ticket"
  end

  it "singularizes games => game" do
    "games".singular.should == "game"
  end

  it "singularizes tournaments => tournament" do
    "tournaments".singular.should == "tournament"
  end

  it "singularizes prizes => prize" do
    "prizes".singular.should == "prize"
  end

  it "singularizes prices => price" do
    "prices".singular.should == "price"
  end

  it "singularizes installations => installation" do
    "installations".singular.should == "installation"
  end

  it "singularizes dates => date" do
    "dates".singular.should == "date"
  end

  it "singularizes schedules => schedule" do
    "schedules".singular.should == "schedule"
  end

  it "singularizes arenas => arena" do
    "arenas".singular.should == "arena"
  end

  it "singularizes spams => spam" do
    "spams".singular.should == "spam"
  end

  it "singularizes rice => rice" do
    "rice".singular.should == "rice"
  end
end
