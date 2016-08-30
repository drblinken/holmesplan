class CoursePlan
  $URL = "http://holmesplace.de/de/schedule/timetableCalendar.json_15_"
  def self.url
    $URL
  end
  def doc
    @doc || @doc = Nokogiri::HTML(open($URL))
  end
end
