class CoursePlan
  $URL = "http://holmesplace.de/de/schedule/timetableCalendar.json_15_"
  def initialize(url = $URL)
    @url = url
  end
  def self.url
    $URL
  end
  def doc
    @doc || @doc = Nokogiri::HTML(open(@url))
  end
  def next_day_id
    element = doc.css("div.headerNextDay")
    element.attribute("data-next-day").value
  end
  def parse_time_and_duration(time_and_duration)
    match = /(.*) \| (\d?\d\d)'/.match(time_and_duration)
    logger.debug "++++ Could not be parsed: #{time_and_duration}" unless match
    start_time = match[1]
    minutes = match[2] ? match[2].to_i : 0
    logger.debug "++++ Duration not found" unless match[2]
    return start_time, minutes
  end
end
