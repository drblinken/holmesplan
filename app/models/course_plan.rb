class CoursePlan
  $URL = "http://holmesplace.de/de/schedule/timetableCalendar.json_15_"
  def initialize(url = $URL, doc = nil)
    @url = url
    @doc = doc
  end
  def self.url
    $URL
  end
  def doc
    @doc || @doc = Nokogiri::HTML(open(@url))
  end

  ## HTML specific methods
  def next_day_id
    element = doc.css("div.headerNextDay")
    element.attribute("data-next-day").value
  end
  def date_header
    doc.css("div.headerColumn")
  end
  def select_date(day)
    day.children[3].text
  end
  def block_selectors
    "div.mor, div.aft, div.nig".split(",")
  end


  def parse_time_and_duration(time_and_duration)
    match = /(.*) \| (\d?\d\d)'/.match(time_and_duration)
    logger.debug "++++ Could not be parsed: #{time_and_duration}" unless match
    start_time = match[1]
    minutes = match[2] ? match[2].to_i : 0
    logger.debug "++++ Duration not found" unless match[2]
    return start_time, minutes
  end


  def parse_calendar
    year = Date.today.year.to_s
    date_strings = date_header.map do | day |
      date = select_date(day)
      "#{date} #{year}"
    end

    block_selectors.map do |block_selector|
      block = doc.css(block_selector)
      day = -1
      block.css("div.dayColumn").map do | dayColumn |
        day = day + 1
        dayColumn.css()
        dayColumn.css("div.timetableProgram").map do |course|
          spans = course.css("span")
          time_and_duration = spans[0].text
          time, duration = parse_time_and_duration(time_and_duration)
          start_time = DateTime.parse("#{date_strings[day]} #{time_and_duration}")
          end_time = start_time + (duration/1440.0)
          course_label = course.css("span.timetableProgramLabel").text
          Event.new(start_time: start_time,end_time: end_time,label: course_label)
        end
      end
    end
  end
end
