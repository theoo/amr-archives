module StringExtention
  def to_utf8
    Iconv.iconv("iso-8859-1", "utf-8", self).to_s
  end

  def cut(max_length = 10)
    # order apply

    return " - " if self == ""
    return self[0...max_length] + "..." if self.length >= max_length
    return self
  end
end

class String
  include StringExtention
end
