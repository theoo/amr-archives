module TimeExtention
  def to_std_datetime
    self.strftime("%Y/%m/%d %H:%M")
  end
end

class Time
  include TimeExtention
end