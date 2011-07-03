module RubyCA
  module Index
    class FileIndex < BaseIndex
      def initialize(options={})
        super()

        @database = options['database']
      end

      attr_reader :database

      def certificates
        @certificates ||= begin
          File.open(@database, 'r') do |f|
            f.flock File::LOCK_SH # Read lock
            f.collect do |line|
              tokens = line.chomp.split("\t")
              next unless tokens.count == 6

              RubyCA::Certificate.new({
                # status is calculated automatically
                :expire_date => str_to_datetime(tokens[1]),
                :revoke_date => str_to_datetime(tokens[2]),
                :serial => tokens[3],
                # file name is calculated automatically
                :dn => tokens[5]
              })
            end
          end
        rescue Errno::ENOENT
          []
        end
      end

      (Certificate::DN_ALIASES.values + %w(serial)).each do |method|
        define_method :"certificates_by_#{method}" do |filter|
          certificates.select{ |cert| cert.send(:"#{method}") == filter }
        end
      end

    protected
      DATETIME_FORMAT="%y%m%d%H%M%S%Z"

      def datetime_to_str(datetime)
        return "" unless datetime
        DateTime.strftime(DATETIME_FORMAT)
      end

      def str_to_datetime(str)
        return nil unless str && !str.empty?
        DateTime.strptime(str, DATETIME_FORMAT)
      end
    end
  end
end
