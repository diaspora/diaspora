require 'spec_helper'
require 'extlib/inflection'

describe Extlib::Inflection, "#singular" do
  it "pluralizes equipment => equipment" do
    "equipment".plural.should == "equipment"
  end

  it "pluralizes information => information" do
    "information".plural.should == "information"
  end

  it "pluralizes money => money" do
    "money".plural.should == "money"
  end

  it "pluralizes species => species" do
    "species".plural.should == "species"
  end

  it "pluralizes series => series" do
    "series".plural.should == "series"
  end

  it "pluralizes fish => fish" do
    "fish".plural.should == "fish"
  end

  it "pluralizes sheep => sheep" do
    "sheep".plural.should == "sheep"
  end

  it "pluralizes news => news" do
    "news".plural.should == "news"
  end

  it "pluralizes rain => rain" do
    "rain".plural.should == "rain"
  end

  it "pluralizes milk => milk" do
    "milk".plural.should == "milk"
  end

  it "pluralizes moose => moose" do
    "moose".plural.should == "moose"
  end

  it "pluralizes hovercraft => hovercraft" do
    "hovercraft".plural.should == "hovercraft"
  end

  it "pluralizes cacti => cactus" do
    "cactus".plural.should == "cacti"
  end

  it "pluralizes thesaurus => thesauri" do
    "thesaurus".plural.should == "thesauri"
  end

  it "pluralizes matrix => matrices" do
    "matrix".plural.should == "matrices"
  end

  it "pluralizes Swiss => Swiss" do
    "Swiss".plural.should == "Swiss"
  end

  it "pluralizes life => lives" do
    "life".plural.should == "lives"
  end

  it "pluralizes wife => wives" do
    "wife".plural.should == "wives"
  end

  it "pluralizes goose => geese" do
    "goose".plural.should == "geese"
  end

  it "pluralizes criterion => criteria" do
    "criterion".plural.should == "criteria"
  end

  it "pluralizes alias => aliases" do
    "alias".plural.should == "aliases"
  end

  it "pluralizes status => statuses" do
    "status".plural.should == "statuses"
  end

  it "pluralizes axis => axes" do
    "axis".plural.should == "axes"
  end

  it "pluralizes crisis => crises" do
    "crisis".plural.should == "crises"
  end

  it "pluralizes testis => testes" do
    "testis".plural.should == "testes"
  end

  it "pluralizes child => children" do
    "child".plural.should == "children"
  end

  it "pluralizes person => people" do
    "person".plural.should == "people"
  end

  it "pluralizes potato => potatoes" do
    "potato".plural.should == "potatoes"
  end

  it "pluralizes tomato => tomatoes" do
    "tomato".plural.should == "tomatoes"
  end

  it "pluralizes buffalo => buffaloes" do
    "buffalo".plural.should == "buffaloes"
  end

  it "pluralizes torpedo => torpedoes" do
    "torpedo".plural.should == "torpedoes"
  end

  it "pluralizes quiz => quizzes" do
    "quiz".plural.should == "quizzes"
  end

  # used to be a bug exposed by this specs suite,
  # this MUST pass or we've got regression
  it "pluralizes vertex => vertices" do
    "vertex".plural.should == "vertices"
  end

  it "pluralizes index => indices" do
    "index".plural.should == "indices"
  end

  it "pluralizes ox => oxen" do
    "ox".plural.should == "oxen"
  end

  it "pluralizes mouse => mice" do
    "mouse".plural.should == "mice"
  end

  it "pluralizes louse => lice" do
    "louse".plural.should == "lice"
  end

  it "pluralizes thesis => theses" do
    "thesis".plural.should == "theses"
  end

  it "pluralizes thief => thieves" do
    "thief".plural.should == "thieves"
  end

  it "pluralizes analysis => analyses" do
    "analysis".plural.should == "analyses"
  end

  it "pluralizes octopus => octopi" do
    "octopus".plural.should == "octopi"
  end

  it "pluralizes grass => grass" do
    "grass".plural.should == "grass"
  end

  it "pluralizes phenomenon => phenomena" do
    "phenomenon".plural.should == "phenomena"
  end





  # ==== bugs, typos and reported issues





  # ==== rules and most common cases

  it "pluralizes forum => forums" do
    "forum".plural.should == "forums"
  end

  it "pluralizes hive => hives" do
    "hive".plural.should == "hives"
  end

  it "pluralizes athlete => athletes" do
    "athlete".plural.should == "athletes"
  end

  it "pluralizes dwarf => dwarves" do
    "dwarf".plural.should == "dwarves"
  end

  it "pluralizes hero => heroes" do
    "hero".plural.should == "heroes"
  end

  it "pluralizes zero => zeroes" do
    "zero".plural.should == "zeroes"
  end

  it "pluralizes man => men" do
    "man".plural.should == "men"
  end

  it "pluralizes woman => women" do
    "woman".plural.should == "women"
  end

  it "pluralizes sportsman => sportsmen" do
    "sportsman".plural.should == "sportsmen"
  end

  it "pluralizes branch => branches" do
    "branch".plural.should == "branches"
  end

  it "pluralizes crunch => crunches" do
    "crunch".plural.should == "crunches"
  end

  it "pluralizes trash => trashes" do
    "trash".plural.should == "trashes"
  end

  it "pluralizes mash => mashes" do
    "mash".plural.should == "mashes"
  end

  it "pluralizes cross => crosses" do
    "cross".plural.should == "crosses"
  end

  it "pluralizes erratum => errata" do
    "erratum".plural.should == "errata"
  end

  # FIXME: add -ia => -ium cases

  # FIXME: add -ra => -rum cases

  it "pluralizes ray => rays" do
    "ray".plural.should == "rays"
  end

  it "pluralizes spray => sprays" do
    "spray".plural.should == "sprays"
  end

  # Merriam-Webster dictionary says
  # preys is correct, too.
  it "pluralizes prey => preys" do
    "prey".plural.should == "preys"
  end

  it "pluralizes toy => toys" do
    "toy".plural.should == "toys"
  end

  it "pluralizes joy => joys" do
    "joy".plural.should == "joys"
  end

  it "pluralizes buy => buys" do
    "buy".plural.should == "buys"
  end

  it "pluralizes guy => guys" do
    "guy".plural.should == "guys"
  end

  it "pluralizes cry => cries" do
    "cry".plural.should == "cries"
  end

  it "pluralizes fly => flies" do
    "fly".plural.should == "flies"
  end

  it "pluralizes fox => foxes" do
    "fox".plural.should == "foxes"
  end

  it "pluralizes elf => elves" do
    "elf".plural.should == "elves"
  end

  it "pluralizes shelf => shelves" do
    "shelf".plural.should == "shelves"
  end

  it "pluralizes plus => plusses" do
    "plus".plural.should == "plusses"
  end

  it "pluralizes cat => cats" do
    "cat".plural.should == "cats"
  end

  it "pluralizes rat => rats" do
    "rat".plural.should == "rats"
  end

  it "pluralizes rose => roses" do
    "rose".plural.should == "roses"
  end

  it "pluralizes project => projects" do
    "project".plural.should == "projects"
  end

  it "pluralizes post => posts" do
    "post".plural.should == "posts"
  end

  it "pluralizes article => articles" do
    "article".plural.should == "articles"
  end

  it "pluralizes location => locations" do
    "location".plural.should == "locations"
  end

  it "pluralizes friend => friends" do
    "friend".plural.should == "friends"
  end

  it "pluralizes link => links" do
    "link".plural.should == "links"
  end

  it "pluralizes url => urls" do
    "url".plural.should == "urls"
  end

  it "pluralizes account => accounts" do
    "account".plural.should == "accounts"
  end

  it "pluralizes server => servers" do
    "server".plural.should == "servers"
  end

  it "pluralizes fruit => fruits" do
    "fruit".plural.should == "fruits"
  end

  it "pluralizes map => maps" do
    "map".plural.should == "maps"
  end

  it "pluralizes income => incomes" do
    "income".plural.should == "incomes"
  end

  it "pluralizes ping => pings" do
    "ping".plural.should == "pings"
  end

  it "pluralizes event => events" do
    "event".plural.should == "events"
  end

  it "pluralizes proof => proofs" do
    "proof".plural.should == "proofs"
  end

  it "pluralizes typo => typos" do
    "typo".plural.should == "typos"
  end

  it "pluralizes attachment => attachments" do
    "attachment".plural.should == "attachments"
  end

  it "pluralizes download => downloads" do
    "download".plural.should == "downloads"
  end

  it "pluralizes asset => assets" do
    "asset".plural.should == "assets"
  end

  it "pluralizes job => jobs" do
    "job".plural.should == "jobs"
  end

  it "pluralizes city => cities" do
    "city".plural.should == "cities"
  end

  it "pluralizes package => packages" do
    "package".plural.should == "packages"
  end

  it "pluralizes commit => commits" do
    "commit".plural.should == "commits"
  end

  it "pluralizes version => versions" do
    "version".plural.should == "versions"
  end

  it "pluralizes document => documents" do
    "document".plural.should == "documents"
  end

  it "pluralizes edition => editions" do
    "edition".plural.should == "editions"
  end

  it "pluralizes movie => movies" do
    "movie".plural.should == "movies"
  end

  it "pluralizes song => songs" do
    "song".plural.should == "songs"
  end

  it "pluralizes invoice => invoices" do
    "invoice".plural.should == "invoices"
  end

  it "pluralizes product => products" do
    "product".plural.should == "products"
  end

  it "pluralizes book => books" do
    "book".plural.should == "books"
  end

  it "pluralizes ticket => tickets" do
    "ticket".plural.should == "tickets"
  end

  it "pluralizes game => games" do
    "game".plural.should == "games"
  end

  it "pluralizes tournament => tournaments" do
    "tournament".plural.should == "tournaments"
  end

  it "pluralizes prize => prizes" do
    "prize".plural.should == "prizes"
  end

  it "pluralizes price => prices" do
    "price".plural.should == "prices"
  end

  it "pluralizes installation => installations" do
    "installation".plural.should == "installations"
  end

  it "pluralizes date => dates" do
    "date".plural.should == "dates"
  end

  it "pluralizes schedule => schedules" do
    "schedule".plural.should == "schedules"
  end

  it "pluralizes arena => arenas" do
    "arena".plural.should == "arenas"
  end

  it "pluralizes spam => spams" do
    "spam".plural.should == "spams"
  end

  it "pluralizes bus => buses" do
    "bus".plural.should == "buses"
  end

  it "pluralizes rice => rice" do
    "rice".plural.should == "rice"
  end

  # Some specs from Rails
  SingularToPlural = {
    "search"      => "searches",
    "switch"      => "switches",
    "fix"         => "fixes",
    "box"         => "boxes",
    "process"     => "processes",
    "address"     => "addresses",
    "case"        => "cases",
    "stack"       => "stacks",
    "wish"        => "wishes",

    "category"    => "categories",
    "query"       => "queries",
    "ability"     => "abilities",
    "agency"      => "agencies",

    "archive"     => "archives",

    "safe"        => "saves",
    "half"        => "halves",

    "move"        => "moves",

    "salesperson" => "salespeople",

    "spokesman"   => "spokesmen",

    "basis"       => "bases",
    "diagnosis"   => "diagnoses",
    "diagnosis_a" => "diagnosis_as",

    "datum"       => "data",
    "medium"      => "media",

    "node_child"  => "node_children",

    "experience"  => "experiences",
    "day"         => "days",

    "comment"     => "comments",
    "foobar"      => "foobars",
    "newsletter"  => "newsletters",

    "old_news"    => "old_news",

    "perspective" => "perspectives",

    "photo"       => "photos",
    "status_code" => "status_codes",

    "house"       => "houses",
    "virus"       => "viruses",
    "portfolio"   => "portfolios",

    "matrix_fu"   => "matrix_fus",

    "axis"        => "axes",

    "shoe"        => "shoes",

    "horse"       => "horses",
    "edge"        => "edges",

    "cow"         => "cows" # 'kine' is archaic and nobody uses it
  }

  SingularToPlural.each do |single_word, plural_word|
    it "pluralizes #{single_word} => #{plural_word}" do
      single_word.plural.should == plural_word
    end
  end
end
