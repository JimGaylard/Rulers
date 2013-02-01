module Rulers
  module Model
    class FileModel
      def initialize(filename)
        @filename = filename

        # if filename is 37.json @id is 37
        basename = File.split(filename)[-1]
        @id = File.basename(basename, ".json").to_i

        obj = File.read(filename)
        @hash = MultiJson.decode(obj)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def self.find(id)
        begin
          FileModel.new("db/quotes/#{id}.json")
        rescue
          raise "FileModel not found"
        end
      end

      def self.all
        files = Dir["db/quotes/*.json"]
        files.map { |f| FileModel.new f }
      end
    end
  end
end
