$: << 'lib'
require 'test/unit'
require "dbi/sql"

# ====================================================================
class TestSqlBind < Test::Unit::TestCase

  def bind(quoter, sql, args)
      ps = DBI::SQL::PreparedStatement.new(quoter, sql)
      ps.bind(DBI::Utils::ConvParam.conv_param('default', *args))
  end

  def test_one
    assert_equal "10", bind(self, "?", [10])
    assert_equal "'hi'", bind(self, "?", ["hi"])
    assert_equal "I 'don''t' know", bind(self, "I ? know", ["don't"])
  end

  def test_many
    assert_equal "WHERE age=12 AND name='Jim'",
      bind(self, "WHERE age=? AND name=?", [12, 'Jim'])
  end

  def test_too_many
    assert_raises (RuntimeError) {
      bind(self, "age=?", [10, 11])
    }
  end

  def test_too_few
    assert_raises (RuntimeError) {
      bind(self, "age in (?, ?, ?)", [10, 11])
    }
  end

  def test_embedded_questions
    assert_equal "10 ? 11", bind(self, "? ?? ?", [10, 11])
    assert_equal "????", bind(self, "????????", [])
  end

  def test_questions_in_param
    assert_equal "WHERE c='connected?'",
      bind(self, "WHERE c=?", ["connected?"])

    assert_equal "WHERE c='connected?' AND d='???'",
      bind(self, "WHERE c=? AND d=?", ["connected?", "???"])
  end

  def test_questions_in_quotes
    assert_equal "WHERE c='connected?' AND d=10",
      bind(self, "WHERE c='connected?' AND d=?", [10])
  end

  def test_comment_dan
    sql = %{--Dan's query\n--random comment\nselect column1, column2\nfrom table1\nwhere somevalue = ?}
    res = %{--Dan's query\n--random comment\nselect column1, column2\nfrom table1\nwhere somevalue = 10}
    assert_equal res, bind(self, sql, [10])
  end

  def test_minus_bug
    sql = "SELECT 1 - 3"
    res = "SELECT 1 - 3"
    assert_equal res, bind(self, sql, []) 
  end

  def test_minus2
    sql = "SELECT * from test --Dan's query" 
    assert_equal sql, bind(self, sql, []) 
  end

  def test_slash
    sql = "SELECT 5 / 4"
    res = "SELECT 5 / 4"
    assert_equal res, bind(self, sql, []) 
  end

  def test_much
    sql = <<ENDSQL
SELECT s.id, cwajga_magic_number((cwajga_product(r.rating) ^ (1 / 1)), MAX(lastplay.lastheard), 5) as magic
INTO TEMP magic_order
FROM song AS s LEFT OUTER JOIN rating AS r ON s.id = r.song LEFT OUTER JOIN last play ON lastplay.song = s.id
WHERE r.name ILIKE 'omega697'
GROUP BY s.id;

SELECT SUM(magic) as total INTO TEMP magic_tot FROM magic_order;

SELECT id, 100.0*magic/total as percent
FROM magic_order, magic_tot
order by percent;
ENDSQL
    res = sql
    assert_equal res, bind(self, sql, [])
  end

  def test_nested_insert
    sql = "insert into logins (user_id, hostmask) values ((select id from users where username = ?), ?)"
    res = sql.sub(/\?/, "1")
    res.sub!(/\?/, "'foo@bar'")
    assert_equal res, bind(self, sql, [1, "foo@bar"])
  end

end

######################################################################
class TestLex < Test::Unit::TestCase

    def tokens(sql)
        DBI::SQL::PreparedStatement.tokens(sql)
    end

  def test_non_strings
    assert_equal ['This is _a t35t'],
      tokens("This is _a t35t")
  end

  def test_simple_strings
    assert_equal ["hi ", "'hello world'"],
      tokens("hi 'hello world'")
    assert_equal ["c = ", "''"],
      tokens("c = ''")
  end

  def test_strings_with_quotes
    assert_equal ["hi ", "'''lo world'"],
      tokens("hi '''lo world'")
    assert_equal ['a', "''''", 'b'],
      tokens("a''''b")
  end

  def test_strings_with_escaped_quotes
    assert_equal ["hi ", "'don\\'t do that'"],
      tokens("hi 'don\\'t do that'")
    assert_equal ['a', "'\\''", 'b'],
      tokens("a'\\''b")
  end

  def test_simple_dq_strings
    assert_equal ["hi ", '"hello world"'],
      tokens('hi "hello world"')
    assert_equal ["c = ", '""'],
      tokens('c = ""')
  end

  def test_dq_strings_with_quotes
    assert_equal ["hi ", '"""lo world"'],
      tokens('hi """lo world"')
    assert_equal ['a', '""""', 'b'],
      tokens('a""""b')
  end

  def test_dq_strings_with_escaped_quotes
    assert_equal ["hi ", '"don\"t do that"'],
      tokens('hi "don\"t do that"')
    assert_equal ['a', '"\""', 'b'],
      tokens('a"\""b')
  end

  def test_qmarks
    assert_equal ["a = ", "?"],
      tokens("a = ?")
    assert_equal ["'?'", " = ", "?"],
      tokens("'?' = ?")
    assert_equal ["'?'", " = ", "??"],
      tokens("'?' = ??")
  end

end

