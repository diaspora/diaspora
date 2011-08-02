# encoding: utf-8
require 'spec_helper'
require 'cucumber/ast/table'

module Cucumber
  module Ast
    describe Table do
      before do
        @table = Table.new([
          %w{one four seven},
          %w{4444 55555 666666}
        ])
        def @table.cells_rows; super; end
        def @table.columns; super; end
      end

      it "should have rows" do
        @table.cells_rows[0].map{|cell| cell.value}.should == %w{one four seven}
      end

      it "should have columns" do
        @table.columns[1].map{|cell| cell.value}.should == %w{four 55555}
      end

      it "should have headers" do
        @table.headers.should == %w{one four seven}
      end

      it "should have same cell objects in rows and columns" do
        # 666666
        @table.cells_rows[1].__send__(:[], 2).should equal(@table.columns[2].__send__(:[], 1))
      end

      it "should know about max width of a row" do
        @table.columns[1].__send__(:width).should == 5
      end

      it "should be convertible to an array of hashes" do
        @table.hashes.should == [
          {'one' => '4444', 'four' => '55555', 'seven' => '666666'}
        ]
      end

      it "should accept symbols as keys for the hashes" do
        @table.hashes.first[:one].should == '4444'
      end

      it "should allow mapping columns" do
        @table.map_column!('one') { |v| v.to_i }
        @table.hashes.first['one'].should == 4444
      end

      it "should allow mapping columns and take a symbol as the column name" do
        @table.map_column!(:one) { |v| v.to_i }
        @table.hashes.first['one'].should == 4444
      end

      it "should allow mapping columns and modify the rows as well" do
        @table.map_column!(:one) { |v| v.to_i }
        @table.rows.first.should include(4444)
        @table.rows.first.should_not include('4444')
      end

      it "should return the row values in order" do
        @table.rows.first.should == %w{4444 55555 666666}
      end

      it "should pass silently if a mapped column does not exist in non-strict mode" do
        lambda {
          @table.map_column!('two', false) { |v| v.to_i }
        }.should_not raise_error
      end

      it "should fail if a mapped column does not exist in strict mode" do
        lambda {
          @table.map_column!('two', true) { |v| v.to_i }
        }.should raise_error('The column named "two" does not exist')
      end

      it "should return the table" do
        (@table.map_column!(:one) { |v| v.to_i }).should == @table
      end

      describe "#match" do
        before(:each) do
          @table = Table.new([
            %w{one four seven},
            %w{4444 55555 666666}
          ])
        end
          
        it "returns nil if headers do not match" do
          @table.match('does,not,match').should be_nil
        end
        it "requires a table: prefix on match" do
          @table.match('table:one,four,seven').should_not be_nil
        end
        it "does not match if no table: prefix on match" do
          @table.match('one,four,seven').should be_nil
        end
      end

      describe "#transpose" do
        before(:each) do
          @table = Table.new([
            %w{one 1111},
            %w{two 22222}
          ])
        end
                
        it "should be convertible in to an array where each row is a hash" do 
          @table.transpose.hashes[0].should == {'one' => '1111', 'two' => '22222'}
        end
      end
      
      describe "#rows_hash" do
                
        it "should return a hash of the rows" do
          table = Table.new([
            %w{one 1111},
            %w{two 22222}
          ])
          table.rows_hash.should == {'one' => '1111', 'two' => '22222'}
        end

        it "should fail if the table doesn't have two columns" do
          faulty_table = Table.new([
            %w{one 1111 abc},
            %w{two 22222 def}
          ])
          lambda {
            faulty_table.rows_hash
          }.should raise_error('The table must have exactly 2 columns')
        end
      end

      describe '#map_headers' do
        it "renames the columns to the specified values in the provided hash" do
          table2 = @table.map_headers('one' => :three)
          table2.hashes.first[:three].should == '4444'
        end

        it "allows renaming columns using regexp" do
          table2 = @table.map_headers(/one|uno/ => :three)
          table2.hashes.first[:three].should == '4444'
        end

        it "copies column mappings" do
          @table.map_column!('one') { |v| v.to_i }
          table2 = @table.map_headers('one' => 'three')
          table2.hashes.first['three'].should == 4444
        end

        it "takes a block and operates on all the headers with it" do
          table = Table.new([
          ['HELLO', 'WORLD'],
          %w{4444 55555}
          ])

          table.map_headers! do |header|
            header.downcase
          end

          table.hashes.first.keys.should =~ %w[hello world]
        end

        it "treats the mappings in the provided hash as overrides when used with a block" do
          table = Table.new([
          ['HELLO', 'WORLD'],
          %w{4444 55555}
          ])

          table.map_headers!('WORLD' => 'foo') do |header|
            header.downcase
          end

          table.hashes.first.keys.should =~ %w[hello foo]
        end

      end

      describe "replacing arguments" do

        before(:each) do
          @table = Table.new([
            %w{qty book},
            %w{<qty> <book>}
          ])
        end

        it "should return a new table with arguments replaced with values" do
          table_with_replaced_args = @table.arguments_replaced({'<book>' => 'Unbearable lightness of being', '<qty>' => '5'})

          table_with_replaced_args.hashes[0]['book'].should == 'Unbearable lightness of being'
          table_with_replaced_args.hashes[0]['qty'].should == '5'
        end

        it "should recognise when entire cell is delimited" do
          @table.should have_text('<book>')
        end

        it "should recognise when just a subset of a cell is delimited" do
          table = Table.new([
            %w{qty book},
            [nil, "This is <who>'s book"]
          ])
          table.should have_text('<who>')
        end

        it "should replace nil values with nil" do
          table_with_replaced_args = @table.arguments_replaced({'<book>' => nil})

          table_with_replaced_args.hashes[0]['book'].should == nil
        end

        it "should preserve values which don't match a placeholder when replacing with nil" do
          table = Table.new([
                              %w{book},
                              %w{cat}
                            ])
          table_with_replaced_args = table.arguments_replaced({'<book>' => nil})
          
          table_with_replaced_args.hashes[0]['book'].should == 'cat'
        end

        it "should not change the original table" do
          @table.arguments_replaced({'<book>' => 'Unbearable lightness of being'})

          @table.hashes[0]['book'].should_not == 'Unbearable lightness of being'
        end

        it "should not raise an error when there are nil values in the table" do
          table = Table.new([
                              ['book', 'qty'],
                              ['<book>', nil],
                            ])
          lambda{ 
            table.arguments_replaced({'<book>' => nil, '<qty>' => '5'})
          }.should_not raise_error
        end

      end
      
      describe "diff!" do
        it "should detect a complex diff" do
          t1 = table(%{
            | 1         | 22          | 333         | 4444         |
            | 55555     | 666666      | 7777777     | 88888888     |
            | 999999999 | 0000000000  | 01010101010 | 121212121212 |
            | 4000      | ABC         | DEF         | 50000        |
          }, __FILE__, __LINE__)
          
          t2 = table(%{
            | a     | 4444     | 1         | 
            | bb    | 88888888 | 55555     | 
            | ccc   | xxxxxxxx | 999999999 | 
            | dddd  | 4000     | 300       |
            | e     | 50000    | 4000      |
          }, __FILE__, __LINE__)
          lambda{t1.diff!(t2)}.should raise_error
          t1.to_s(:indent => 12, :color => false).should == %{
            |     1         | (-) 22         | (-) 333         |     4444         | (+) a    |
            |     55555     | (-) 666666     | (-) 7777777     |     88888888     | (+) bb   |
            | (-) 999999999 | (-) 0000000000 | (-) 01010101010 | (-) 121212121212 | (+)      |
            | (+) 999999999 | (+)            | (+)             | (+) xxxxxxxx     | (+) ccc  |
            | (+) 300       | (+)            | (+)             | (+) 4000         | (+) dddd |
            |     4000      | (-) ABC        | (-) DEF         |     50000        | (+) e    |
          }
        end

        it "should not change table when diffed with identical" do
          t = table(%{
            |a|b|c|
            |d|e|f|
            |g|h|i|
          }, __FILE__, __LINE__)
          t.diff!(t.dup)
          t.to_s(:indent => 12, :color => false).should == %{
            |     a |     b |     c |
            |     d |     e |     f |
            |     g |     h |     i |
          }
        end

        it "should inspect missing and surplus cells" do
          t1 = Table.new([
            ['name',  'male', 'lastname', 'swedish'],
            ['aslak', 'true', 'hellesøy', 'false']
          ])
          t2 = Table.new([
            ['name',  'male', 'lastname', 'swedish'],
            ['aslak', true,   'hellesøy', false]
          ])
          lambda{t1.diff!(t2)}.should raise_error

          t1.to_s(:indent => 12, :color => false).should == %{
            |     name  |     male       |     lastname |     swedish     |
            | (-) aslak | (-) (i) "true" | (-) hellesøy | (-) (i) "false" |
            | (+) aslak | (+) (i) true   | (+) hellesøy | (+) (i) false   |
          }
        end

        it "should allow column mapping of target before diffing" do
          t1 = Table.new([
            ['name',  'male'],
            ['aslak', 'true']
          ])
          t1.map_column!('male') { |m| m == 'true' }
          t2 = Table.new([
            ['name',  'male'],
            ['aslak', true]
          ])
          t1.diff!(t2)
          t1.to_s(:indent => 12, :color => false).should == %{
            |     name  |     male |
            |     aslak |     true |
          }
        end

        it "should allow column mapping of argument before diffing" do
          t1 = Table.new([
            ['name',  'male'],
            ['aslak', true]
          ])
          t1.map_column!('male') { 
            'true'
          }
          t2 = Table.new([
            ['name',  'male'],
            ['aslak', 'true']
          ])
          t2.diff!(t1)
          t1.to_s(:indent => 12, :color => false).should == %{
            |     name  |     male |
            |     aslak |     true |
          }
        end

        it "should allow header mapping before diffing" do
          t1 = Table.new([
            ['Name',  'Male'],
            ['aslak', 'true']
          ])
          t1.map_headers!('Name' => 'name', 'Male' => 'male')
          t1.map_column!('male') { |m| m == 'true' }
          t2 = Table.new([
            ['name',  'male'],
            ['aslak', true]
          ])
          t1.diff!(t2)
          t1.to_s(:indent => 12, :color => false).should == %{
            |     name  |     male |
            |     aslak |     true |
          }
        end

        it "should detect seemingly identical tables as different" do
          t1 = Table.new([
            ['X',  'Y'],
            ['2', '1']
          ])
          t2 = Table.new([
            ['X',  'Y'],
            [2, 1]
          ])
          lambda{t1.diff!(t2)}.should raise_error
          t1.to_s(:indent => 12, :color => false).should == %{
            |     X       |     Y       |
            | (-) (i) "2" | (-) (i) "1" |
            | (+) (i) 2   | (+) (i) 1   |
          }
        end

        it "should not allow mappings that match more than 1 column" do
          t1 = Table.new([
            ['Cuke',  'Duke'],
            ['Foo', 'Bar']
          ])
          lambda do
            t1.map_headers!(/uk/ => 'u')
          end.should raise_error(%{2 headers matched /uk/: ["Cuke", "Duke"]})
        end
        
        describe "raising" do
          before do
            @t = table(%{
              | a | b |
              | c | d |
            }, __FILE__, __LINE__)
            @t.should_not == nil
          end
          
          it "should raise on missing rows" do
            t = table(%{
              | a | b |
            }, __FILE__, __LINE__)
            lambda { @t.dup.diff!(t) }.should raise_error
            lambda { @t.dup.diff!(t, :missing_row => false) }.should_not raise_error
          end

          it "should not raise on surplus rows when surplus is at the end" do
            t = table(%{
              | a | b |
              | c | d |
              | e | f |
            }, __FILE__, __LINE__)
            lambda { @t.dup.diff!(t) }.should raise_error
            lambda { @t.dup.diff!(t, :surplus_row => false) }.should_not raise_error
          end

          it "should not raise on surplus rows when surplus is interleaved" do
            t1 = table(%{
              | row_1 | row_2 |
              | four  | 4     |
            }, __FILE__, __LINE__)
            t2 = table(%{
              | row_1 | row_2 |
              | one   | 1     |
              | two   | 2     |
              | three | 3     |
              | four  | 4     |
              | five  | 5     |
            }, __FILE__, __LINE__)
            lambda { t1.dup.diff!(t2) }.should raise_error

            begin
              pending "http://groups.google.com/group/cukes/browse_thread/thread/5d96431c8245f05f" do
                lambda { t1.dup.diff!(t2, :surplus_row => false) }.should_not raise_error
              end
            rescue => e
              warn(e.message + " - see http://www.ruby-forum.com/topic/208508")
            end
          end

          it "should raise on missing columns" do
            t = table(%{
              | a |
              | c |
            }, __FILE__, __LINE__)
            lambda { @t.dup.diff!(t) }.should raise_error
            lambda { @t.dup.diff!(t, :missing_col => false) }.should_not raise_error
          end

          it "should not raise on surplus columns" do
            t = table(%{
              | a | b | x |
              | c | d | y |
            }, __FILE__, __LINE__)
            lambda { @t.dup.diff!(t) }.should_not raise_error
            lambda { @t.dup.diff!(t, :surplus_col => true) }.should raise_error
          end
        end

        def table(text, file, offset)
          Table.parse(text, file, offset)
        end
      end

      describe "#new" do
        it "should allow Array of Hash" do
          t1 = Table.new([{'name' => 'aslak', 'male' => 'true'}])
          t1.to_s(:indent => 12, :color => false).should == %{
            |     name  |     male |
            |     aslak |     true |
          }
        end
      end

      it "should convert to sexp" do
        @table.to_sexp.should == 
          [:table, 
            [:row, -1,
              [:cell, "one"], 
              [:cell, "four"],
              [:cell, "seven"]
            ],
            [:row, -1,
              [:cell, "4444"], 
              [:cell, "55555"],
              [:cell, "666666"]]]
      end
    end
  end
end
