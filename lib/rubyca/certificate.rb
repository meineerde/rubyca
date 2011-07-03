module RubyCA
  class Certificate
    def initialize(args={})
      args.each_pair do |arg, value|
        send(:"#{arg}=", value)
      end
    end

    STATUS = {:valid => 'V',
              :revoked => 'R',
              :expired => 'E'
             }

    def status; @status || STATUS[:valid]; end
    def valid?; status == STATUS[:valid]; end

    %w(expire revoke).each do |name|
      define_method :"#{name}d?" do
        status == STATUS[:"#{name}d"]
      end

      attr_reader :"#{name}_date"

      define_method :"#{name}_date=" do |date|
        raise ArgumentError.new("I need a DateTime!") unless date.nil? || date.is_a?(Date)
        if date.nil?
          case :"#{name}"
          when :expire
            @status = STATUS[:valid] unless revoked?
          when :revoke
            if revoked? && expire_date && expire_date <= DateTime.now
              @status = STATUS[:expired]
            else
              @status = STATUS[:valid]
            end
          end

        elsif (date <= DateTime.now)
          case :"#{name}"
          when :expire
            @status = STATUS[:expired] if valid?
          when :revoke
            @status = STATUS[:revoked] if valid? || expired?
          end
        end
        instance_variable_set("@#{name}_date", date)
      end
    end

    attr_accessor :serial

    def dn; @dn ||= Hash.new; end
    def dn=(str)
      @dn = OpenSSL::X509::Name.parse(str).to_a.inject({}) do |dn, field|
        dn[field[0]] = field[1]
        dn
      end
    end

    DN_ALIASES = {'C' => :country,
                  'ST' => :state,
                  'L' => :location,
                  'O' => :organization,
                  'OU' => :ou,
                  'emailAddress' => :email,
                  'name' => :name,
                  'CN' => :cn
                 }
    DN_ALIASES.each_pair do |field, method_name|
      define_method method_name do
        dn[field]
      end
    end

    def verify(fix_me = false)
      # TODO: verify all fields from key file
    end
  end
end