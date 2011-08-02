module DBI
    module Utils
        # Formats results in XML.
        module XMLFormatter
            # Generate XML for a row. The column names will surround the the values as tags.
            #
            # * +dbrow+: the array of the result row.
            # * +rowtag+: the name of the tag that encapsulates a row.
            # * +output+: Object that responds to `<<`.
            #
            def self.row(dbrow, rowtag="row", output=STDOUT)
                #XMLFormatter.extended_row(dbrow, "row", [],  
                output << "<#{rowtag}>\n"
                dbrow.each_with_name do |val, name|
                    output << "  <#{name}>" + textconv(val) + "</#{name}>\n" 
                end
                output << "</#{rowtag}>\n"
            end

            # good lord, what a mess.
            #
            # nil in cols_as_tag, means "all columns expect those listed in cols_in_row_tag"
            # add_row_tag_attrs are additional attributes which are inserted into the row-tag
            def self.extended_row(dbrow, rowtag="row", cols_in_row_tag=[], cols_as_tag=nil, add_row_tag_attrs={}, output=STDOUT)
                if cols_as_tag.nil?
                    cols_as_tag = dbrow.column_names - cols_in_row_tag
                end

                output << "<#{rowtag}"
                add_row_tag_attrs.each do |key, val|  
                    # TODO: use textconv ? " substitution?
                    output << %{ #{key}="#{textconv(val)}"}
                end
                cols_in_row_tag.each do |key|
                    # TODO: use textconv ? " substitution?
                    output << %{ #{key}="#{dbrow[key]}"}
                end
                output << ">\n"

                cols_as_tag.each do |key|
                    output << "  <#{key}>" + textconv(dbrow[key]) + "</#{key}>\n" 
                end
                output << "</#{rowtag}>\n"
            end

            # generate a full XML representation of the table.
            # 
            # Arguments and output are similar to #row, with the exception of
            # +roottag+, which is a container for the individual row tags.
            #
            def self.table(rows, roottag = "rows", rowtag = "row", output=STDOUT)
                output << '<?xml version="1.0" encoding="UTF-8" ?>'
                output << "\n<#{roottag}>\n"
                rows.each do |row|
                    row(row, rowtag, output)
                end
                output << "</#{roottag}>\n"
            end

            class << self
                private
                # Your standard XML entity conversions.
                def textconv(str)
                    str = str.to_s.gsub('&', "&#38;")
                    str = str.gsub('\'', "&#39;")
                    str = str.gsub('"', "&#34;")
                    str = str.gsub('<', "&#60;")
                    str.gsub('>', "&#62;")
                end
            end # class self
        end # module XMLFormatter
    end
end
