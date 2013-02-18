#coding: utf-8

module Fluent
  class ArangoOutput < BufferedOutput
    Fluent::Plugin.register_output('arango', self)
    
    include Fluent::SetTagKeyMixin
    config_set_default :include_tag_key, true

    include Fluent::SetTimeKeyMixin
    config_set_default :include_time_key, true

    config_param :scheme, :string, :default => 'http'
    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer, :default => 8529
    config_param :collection, :string
    config_param :username, :string, :default => nil
    config_param :password, :string, :default => nil

    def initialize
      super
      require 'ashikawa-core'
      require 'msgpack'

      @db = nil
      @conn = nil
      @col = nil
    end

    def configure(conf)
      super
    end


    def start
      super

      @conn = Ashikawa::Core::Connection.new(get_arango_url)
      if @username && @password then
        @conn.authenticate_with(:username => @username, :password => @password)
      end
      @db = Ashikawa::Core::Database.new(@conn)
      @col = @db[@collection]
    end

    def shutdown
      # MEMO: Ashikawa-Core has not finalize-method.
      super
    end

    def format(tag, time, record)
      return record.to_msgpack
    end

    #def emit(tag, es, chain)
    #end

    def write(chunk)
      # TODO: Change to bulk import if Ashikawa-core implemented.
      chunk.msgpack_each do |record|
        @col.create(record)
      end
    end


    private

    def get_arango_url
      return "#{@scheme}://#{@host}:#{@port}"
    end

  end
end

