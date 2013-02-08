require 'sqlite3'
require 'rulers/util'

DB_CONN = SQLite3::Database.new "test.rb"

module Rulers
  module Model
    class SQLite
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
