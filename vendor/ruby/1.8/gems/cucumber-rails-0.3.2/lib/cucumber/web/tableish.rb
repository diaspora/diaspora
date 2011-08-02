require 'nokogiri'

module Cucumber
  module Web
    module Tableish
      # This method returns an Array of Array of String, using CSS3 selectors.
      # This is particularly handy when using Cucumber's Table#diff! method.
      #
      # The +row_selector+ argument must be a String, and picks out all the rows
      # from the web page's DOM. If the number of cells in each row differs, it
      # will be constrained by (or padded with) the number of cells in the first row
      #
      # The +column_selectors+ argument must be a String or a Proc, picking out
      # cells from each row. If you pass a Proc, it will be yielded an instance
      # of Nokogiri::HTML::Element.
      #
      # == Example with a table
      #
      #   <table id="tools">
      #     <tr>
      #       <th>tool</th>
      #       <th>dude</th>
      #     </tr>
      #     <tr>
      #       <td>webrat</td>
      #       <td>bryan</td>
      #     </tr>
      #     <tr>
      #       <td>cucumber</td>
      #       <td>aslak</td>
      #     </tr>
      #   </table>
      #
      #   t = tableish('table#tools tr', 'td,th')
      #
      # == Example with a dl
      #
      #   <dl id="tools">
      #     <dt>webrat</dt>
      #     <dd>bryan</dd>
      #     <dt>cucumber</dt>
      #     <dd>aslak</dd>
      #   </dl>
      #
      #   t = tableish('dl#tools dt', lambda{|dt| [dt, dt.next.next]})
      #
      def tableish(row_selector, column_selectors)
        html = defined?(Capybara) ? body : response_body
        _tableish(html, row_selector, column_selectors)
      end

      def _tableish(html, row_selector, column_selectors) #:nodoc
        doc = Nokogiri::HTML(html)
        spans = nil
        max_cols = 0

        # Parse the table.
        rows = doc.search(row_selector).map do |row|
          cells = case(column_selectors)
          when String
            row.search(column_selectors)
          when Proc
            column_selectors.call(row)
          end

          # TODO: max_cols should be sum of colspans
          max_cols = [max_cols, cells.length].max

          spans ||= Array.new(max_cols, 1)

          cell_index = 0

          cells = (0...spans.length).inject([]) do |array, n|
            span = spans[n]

            cell = if span > 1
              row_span, col_span = 1, 1
              nil
            else
              cell = cells[cell_index]

              row_span, col_span = _parse_spans(cell)

              if col_span > 1
                ((n + 1)...(n + col_span)).each do |m|
                  spans[m] = row_span + 1
                end
              end

              cell_index +=1
              cell
            end

            spans[n] = row_span > 1 ? row_span : ([span - 1, 1].max)

            array << case cell
              when String then cell.strip
              when nil then ''
              else cell.text.strip
            end

            array
          end

          cells
        end
      end

      def _parse_spans(cell)
        cell.is_a?(Nokogiri::XML::Node) ?
          [cell.attributes['rowspan'].to_s.to_i || 1, cell.attributes['colspan'].to_s.to_i || 1] :
          [1, 1]
      end
    end
  end
end

World(Cucumber::Web::Tableish)
