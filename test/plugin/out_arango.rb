# coding: utf-8
require 'fluent/test'
require 'ashikawa-core'
require 'msgpack'

class ArangoOutputTest < Test::Unit::TestCase
  
  DEFAULT_COL = 'ut_col'
  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 8529
  CONFIG = %[
    type arango
    collection  #{DEFAULT_COL}
    host        #{DEFAULT_HOST}
    port        #{DEFAULT_PORT}
  ]
  ARANGO_URL = "http://#{DEFAULT_HOST}:#{DEFAULT_PORT}"
  
  def setup
    Fluent::Test.setup
    # HACK: Avoid Error "Encoding::UndefinedConversionError: U+00FC from UTF-8 to ASCII-8BIT"
    Encoding.default_internal = Encoding::UTF_8
    require 'fluent/plugin/out_arango'

    # TODO: AUTH case
    # TODO: Start/Stop ArangoDB from Ruby-Script

    # drop collection
    @con = Ashikawa::Core::Connection.new(ARANGO_URL)
    @db = Ashikawa::Core::Database.new(@con)
    @col = @db[DEFAULT_COL]
    @col.delete

  end
  
  def teardown
    
  end

  def create_driver(conf = CONFIG)
    return Fluent::Test::BufferedOutputTestDriver.new(Fluent::ArangoOutput).configure(conf)
  end

  def test_configure_no_parameter
    # assert_throws .. 
    begin
      driver = create_driver(%[
        type arango
      ])
      flunk "fail"
    rescue Fluent::ConfigError
      assert_equal $!.message, "'collection' parameter is required"
    rescue
      flunk "fail"
    end
  end

  def test_configure
    d = create_driver(%[
      type arango
      collection ut_col
    ])
    assert_equal 'ut_col', d.instance.collection
    # default parameter
    assert_equal 'http', d.instance.scheme
    assert_equal 'localhost', d.instance.host
    assert_equal 8529, d.instance.port
    assert_equal nil, d.instance.username
    assert_equal nil, d.instance.password
  end

  def test_format
    d = create_driver()
    
    tag = "test"
    time = Time.parse("2013-02-28 23:59:59 UTC").to_i  # 1362095999
    d.emit({"a" => 1}, time)
    d.emit({"a" => 2}, time)

    d.expect_format({"a" => 1, "tag" => tag, "time" => "2013-02-28T23:59:59Z"}.to_msgpack)
    d.expect_format({"a" => 2, "tag" => tag, "time" => "2013-02-28T23:59:59Z"}.to_msgpack)

    d.run
  end

  def test_format_time
    d = create_driver(CONFIG + %[
      time_format %Y-%m-%d %H:%M:%S
      time_key mytime
    ])
    d.emit({"a" => 1}, Time.parse("2013-02-28 23:59:59 UTC").to_i)
    
    d.expect_format({"a" => 1, "tag" => "test", "mytime" => "2013-02-28 23:59:59"}.to_msgpack)

    d.run
  end

  def test_write

    d = create_driver()
    
    tag = "test"
    time = Time.parse("2012-02-28 23:59:59 UTC").to_i
    d.emit({"b" => 1}, time)
    d.emit({"b" => 2}, time)
    d.run

    # MEMO: first_example does not running.. bug?
    #cursor = @col.query.execute(%[FOR t IN #{DEFAULT_COL} FILTER t.b == 1 RETURN t])
    doc1 = @col.query.by_example(b:1).detect{true}
    assert_equal 1, doc1["b"]
    assert_equal tag, doc1["tag"]
    assert_equal "2012-02-28T23:59:59Z", doc1["time"]

    doc2 = @col.query.by_example(b:2).detect{true}
    assert_equal 2, doc2["b"]
    assert_equal tag, doc2["tag"]
    assert_equal "2012-02-28T23:59:59Z", doc2["time"]

  end

end

