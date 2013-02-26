require 'sqlite3'
require 'rulers/util'
require 'pry'

DB_CONN = SQLite3::Database.new "test.db"

module Rulers
  module Model
    class SQLite
      def initialize(data = nil)
        @hash = data
      end

      def self.to_sql(val)
        case val
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL!"
        end
      end

      def self.create(values)
        values.delete "id"
        keys = schema.keys - ["id"]
        vals = keys.map do |key|
          values[key] ? to_sql(values[key]) : "null"
        end


        DB_CONN.execute <<SQL
  INSERT INTO #{table} (#{keys.join ","})
    VALUES (#{vals.join ","});
SQL
        data = Hash[keys.zip vals]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB_CONN.execute(sql)[0][0]
        self.new data
      end

      def self.find(id)
        binding.pry
        row = DB_CONN.execute <<SQL
SELECT #{schema.keys.join(",")} FROM #{table}
WHERE id = #{id};
SQL
        data = Hash[schema.keys.zip row[0]]
        self.new data

      end

      def self.count
        DB_CONN.execute(<<SQL)[0][0]
SELECT COUNT (*) FROM #{table}
SQL
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def self.table
        Rulers.to_underscore name
      end

      def self.schema
        return @schema if @schema
        @schema = {}
        DB_CONN.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end
        @schema
      end
    end
  end
end
