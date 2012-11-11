module URI

  def self.encode_www_form(enum)
    enum.map do |k,v|
      k = k.to_s

      if v.nil?
        k
      elsif v.respond_to?(:to_ary)
        v.to_ary.map do |w|
          w = w.to_s
          str = k.dup
          unless w.nil?
            str << '='
            str << w
          end
        end.join('&')
      else
        str = k.dup
        str << '='
        str << v.to_s
      end
    end.join('&')
  end

end