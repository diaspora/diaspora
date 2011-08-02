Shindo.tests("Formatador") do

output = <<-OUTPUT
    +---+
    | \e[1ma\e[0m |
    +---+
    | 1 |
    +---+
    | 2 |
    +---+
OUTPUT

  tests("#display_table([{:a => 1}, {:a => 2}])").returns(output) do
    capture_stdout do
      Formatador.display_table([{:a => 1}, {:a => 2}])
    end
  end

output = <<-OUTPUT
    +--------+
    | \e[1mheader\e[0m |
    +--------+
    +--------+
OUTPUT

  tests("#display_table([], [:header])").returns(output) do
    capture_stdout do
      Formatador.display_table([], [:header])
    end
  end

output = <<-OUTPUT
    +--------+
    | \e[1mheader\e[0m |
    +--------+
    |        |
    +--------+
OUTPUT

  tests("#display_table([{:a => 1}], [:header])").returns(output) do
    capture_stdout do
      Formatador.display_table([{:a => 1}], [:header])
    end
  end

end
