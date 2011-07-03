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

      def save
        File.open(@database, File::WRONLY|File::APPEND|File::CREAT, 0644) do |f|
          f.flock File::LOCK_EX
          f.truncate 0

          certificates.select(&:saved?).sort_by(&:serial).each do |crt|
            line = [crt.status, crt.expire_date, crt.revoke_date,
                    crt.serial, crt.certificate_filenname, crt.dn].join("\t")
            f.write("#{line}\n")
          end
          f.flush
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
