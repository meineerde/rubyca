module RubyCA
  class BaseIndex
    def certificates
      # please override me in a subclass :)
      @certificates ||= []
    end

    def save
      # please override me in a subclass :)
      false
    end

    (Certificate::DN_ALIASES.values + %w(serial)).each do |method|
      define_method :"certificates_by_#{method}" do |filter|
        certificates.select{ |cert| cert.send(:"#{method}") == filter }
      end
    end
  end
end