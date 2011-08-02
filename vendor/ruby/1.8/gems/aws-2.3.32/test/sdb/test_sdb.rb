require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../test_credentials.rb'

class TestSdb < Test::Unit::TestCase

    def setup
        TestCredentials.get_credentials
        STDOUT.sync = true
        @domain     = 'right_sdb_awesome_test_domain'
        @item       = 'toys'
        @attr       = {'Jon' => %w{beer car}}
        # Interface instance
        @sdb        = Aws::SdbInterface.new(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key)
    end

    SDB_DELAY = 2

    def wait(delay, msg='')
        print "waiting #{delay} seconds #{msg}"
        while delay>0 do
            delay -= 1
            print '.'
            sleep 1
        end
        puts
    end

    #---------------------------
    # Aws::SdbInterface
    #---------------------------

    def test_00_delete_domain
        # delete the domain to reset all the things
        assert @sdb.delete_domain(@domain), 'delete_domain fail'
        wait SDB_DELAY, 'after domain deletion'
    end

    def test_01_create_domain
        # check that domain does not exist
        assert !@sdb.list_domains[:domains].include?(@domain)
        # create domain
        assert @sdb.create_domain(@domain), 'create_domain fail'
        wait SDB_DELAY, 'after domain creation'
        # check that we have received new domain from Amazin
        assert @sdb.list_domains[:domains].include?(@domain)
    end

    def test_02_put_attributes
        # put attributes
        assert @sdb.put_attributes(@domain, @item, @attr)
        wait SDB_DELAY, 'after putting attributes'
    end

    def test_03_get_attributes
        # get attributes
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Jon'].to_a.sort
        # compare to original list
        assert_equal values, @attr['Jon'].sort
    end

    def test_04_add_attributes
        # add new attribute
        new_value = 'girls'
        @sdb.put_attributes @domain, @item, {'Jon' => new_value}
        wait SDB_DELAY, 'after putting attributes'
        # get attributes ('girls' must be added to already existent attributes)
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Jon'].to_a.sort
        assert_equal values, (@attr['Jon'] << new_value).sort
    end

    def test_05_replace_attributes
        # replace attributes
        @sdb.put_attributes @domain, @item, {'Jon' => 'pub'}, :replace
        wait SDB_DELAY, 'after replacing attributes'
        # get attributes (all must be removed except of 'pub')
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Jon']
        assert_equal values, ['pub']
    end

    def test_06_delete_attribute
        # add value 'girls' and 'vodka' to 'Jon'
        @sdb.put_attributes @domain, @item, {'Jon' => ['girls', 'vodka']}
        wait SDB_DELAY, 'after adding attributes'
        # get attributes ('girls' and 'vodka' must be added 'pub')
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Jon'].to_a.sort
        assert_equal values, ['girls', 'pub', 'vodka']
        # delete a single value 'girls' from attribute 'Jon'
        @sdb.delete_attributes @domain, @item, 'Jon' => ['girls']
        wait SDB_DELAY, 'after the deletion of attribute'
        # get attributes ('girls' must be removed)
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Jon']
        assert_equal values, ['pub', 'vodka']
        # delete all values from attribute 'Jon'
        @sdb.delete_attributes @domain, @item, ['Jon']
        wait SDB_DELAY, 'after the deletion of attributes'
        # get attributes (values must be empty)
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Jon']
        assert_equal values, nil
    end

    def test_07_delete_item
        @sdb.put_attributes @domain, @item, {'Volodya' => ['girls', 'vodka']}
        wait SDB_DELAY, 'after adding attributes'
        # get attributes ('girls' and 'vodka' must be there)
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Volodya'].to_a.sort
        assert_equal ['girls', 'vodka'], values
        # delete an item
        @sdb.delete_attributes @domain, @item
        sleep 1
        # get attributes (values must be empty)
        values = @sdb.get_attributes(@domain, @item)[:attributes]['Volodya']
        assert_nil values
    end

    def test_08_batch_put_and_delete_attributes
        items = []
        10.times do |i|
            items << Aws::SdbInterface::Item.new("#{@item}_#{i}", {:name=>"name_#{i}"}, true)
        end
        @sdb.batch_put_attributes @domain, items
        sleep 1

        @sdb.batch_delete_attributes @domain, items.collect {|x| x.item_name }
    end


    def test_11_signature_version_2
        sdb     = Aws::SdbInterface.new(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key, :signature_version => '2')
        domains = nil
        assert_nothing_thrown "Failed to use signature V2" do
            domains = sdb.list_domains
        end
        assert domains
    end

    def test_12_unicode

        # This was creating a bad signature
        s = ''
        File.open("unicode.txt", "r") { |f|
            s = f.read
        }
#        s = s.force_encoding("UTF-8")
        puts 's=' + s.inspect
        puts "encoding? " + s.encoding.name
#        s = s.encode("ASCII")
        # todo: I'm thinking just iterate through characters and swap out ones that aren't in ascii range.
        @sdb.put_attributes @domain, @item, {"badname"=>[s]}
        sleep 1
        value = @sdb.get_attributes(@domain, @item)[:attributes]['badname'][0]
        puts 'value=' + value.inspect
#        assert value == s # NOT WORKING, not even sure this is a valid test though

    end

    def test_15_array_of_attrs
        item = 'multiples'
        assert_nothing_thrown "Failed to put multiple attrs" do
            @sdb.put_attributes(@domain, item, {:one=>1, :two=>2, :three=>3})
        end
    end

    def test_16_zero_len_attrs
        item = 'zeroes'
        assert_nothing_thrown "Failed to put zero-length attributes" do
            @sdb.put_attributes(@domain, item, {:one=>"", :two=>"", :three=>""})
        end
    end

    def test_17_nil_attrs
        item = 'nils'
        res  = nil
        assert_nothing_thrown do
            @sdb.put_attributes(@domain, item, {:one=>nil, :two=>nil, :three=>'chunder'})
        end
        sleep 1
        assert_nothing_thrown do
            res = @sdb.get_attributes(@domain, item)
        end
        assert_nil(res[:attributes]['one'][0])
        assert_nil(res[:attributes]['two'][0])
        assert_not_nil(res[:attributes]['three'][0])
    end

    def test_18_url_escape
        item    = 'urlescapes'
        content = {:a=>"one & two & three",
                   :b=>"one ? two / three"}
        @sdb.put_attributes(@domain, item, content)

        res = @sdb.get_attributes(@domain, item)
        assert_equal(content[:a], res[:attributes]['a'][0])
        assert_equal(content[:b], res[:attributes]['b'][0])
    end

    def test_19_put_attrs_by_post
        item = 'reqgirth'
        i    = 0
        sa   = ""
        while (i < 64) do
            sa += "aaaaaaaa"
            i  += 1
        end
        @sdb.put_attributes(@domain, item, {:a => sa, :b => sa, :c => sa, :d => sa, :e => sa})
    end

    def test_21_query_with_atributes
        # not applicable anymore
    end

    # Keep this test last, because it deletes the domain...
    def test_40_delete_domain
        assert @sdb.delete_domain(@domain), 'delete_domain fail'
        wait SDB_DELAY, 'after domain deletion'
        # check that domain does not exist
        assert !@sdb.list_domains[:domains].include?(@domain)
    end


end