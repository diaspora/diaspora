class Formatador
  def display_table(hashes, keys = nil, &block)
    new_hashes = hashes.inject([]) do |accum,item|
      accum << :split unless accum.empty?
      accum << item
    end
    display_compact_table(new_hashes, keys, &block)
  end

  def display_compact_table(hashes, keys = nil, &block)
    headers = keys || []
    widths = {}
    if hashes.empty? && keys
      for key in keys
        widths[key] = key.to_s.length
      end
    else
      for hash in hashes
        next unless hash.respond_to?(:keys)

        for key in hash.keys
          unless keys
            headers << key
          end
          widths[key] = [ length(key), widths[key] || 0, hash[key] && length(hash[key]) || 0].max
        end
        headers = headers.uniq
      end
    end

    if block_given?
      headers = headers.sort(&block)
    elsif !keys
      headers = headers.sort {|x,y| x.to_s <=> y.to_s}
    end

    split = "+"
    if headers.empty?
      split << '--+'
    else
      for header in headers
        widths[header] ||= length(header)
        split << ('-' * (widths[header] + 2)) << '+'
      end
    end

    display_line(split)
    columns = []
    for header in headers
      columns << "[bold]#{header}[/]#{' ' * (widths[header] - header.to_s.length)}"
    end
    display_line("| #{columns.join(' | ')} |")
    display_line(split)

    for hash in hashes
      if hash.respond_to? :keys
        columns = []
        for header in headers
          datum = hash[header] || ''
          columns << "#{datum}#{' ' * (widths[header] - length(datum))}"
        end
        display_line("| #{columns.join(' | ')} |")
      else
        if hash == :split
          display_line(split)
        end 
      end
      nil
    end
    display_line(split)
  end

  private

  def length(value)
    value.to_s.gsub(PARSE_REGEX, '').length
  end
end
