class WeekController < ApplicationController
  def courses
    require 'icalendar/tzinfo'

    cal = Icalendar::Calendar.new
    tzid = 'Europe/Berlin'
    tz = TZInfo::Timezone.get tzid

    event_start = DateTime.new(2016,8,30,9,0,0)
    timezone = tz.ical_timezone event_start
    cal.add_timezone timezone

    url = "http://holmesplace.de/de/schedule/timetableCalendar.json_15_"
    doc = Nokogiri::HTML(open(url))

    parse_calendar(doc,cal,tzid)

    render plain: cal.to_ical
  end

private

def parse_time_and_duration(time_and_duration)
  match = /(.*) \| (\d?\d\d)'/.match(time_and_duration)
  puts "++++ Could not be parsed: #{time_and_duration}" unless match
  start_time = match[1]
  minutes = match[2] ? match[2].to_i : 0
  puts "++++ Duration not found" unless match[2]
  return start_time, minutes
end
def parse_calendar(doc,cal,tzid)
  year = Date.today.year.to_s
  dates = []
  date_strings = []
  doc.css("div.headerColumn").each do | day |
    # <div class="headerColumn"><span></span>Dienstag<br><span>30 August</span></div>
    children = day.children
    day = children[1].text
    date = children[3].text
    puts "date #{date}"
    dates << Date.parse(date)
    date_strings << "#{date} #{year}"
    puts "day: #{day} date: #{date}"
  end

  puts dates.inspect
  puts date_strings.inspect

  #blocks = "div.mor".split
  #blocks = "div.aft".split
  blocks = "div.nig".split
  blocks = "div.mor, div.aft, div.nig".split(",")
  puts "blocks: #{blocks}"
  blocks.each do |block_selector|
    puts "++++ Starting on block #{block_selector}"
    block = doc.css(block_selector)
    puts "++++ this block has #{block.css("div.dayColumn").size} days"
    day = -1
    block.css("div.dayColumn").each do | dayColumn |
      day = day + 1
      puts "DAY: #{dates[day]}"
      dayColumn.css()
      #puts dayColumn.class
      dayColumn.css("div.timetableProgram").each do |course|
        spans = course.css("span")
        time_and_duration = spans[0].text
        time, duration = parse_time_and_duration(time_and_duration)
        puts "time #{time_and_duration}"
        start_time = DateTime.parse("#{date_strings[day]} #{time_and_duration}")
        end_time = start_time + (duration/1440.0)
        puts "start_time: #{start_time.inspect}"
        puts "end_time:   #{end_time.inspect}"
        course_label = course.css("span.timetableProgramLabel").text
        puts "course #{course_label}"
        cal.event do |e|
          e.dtstart = Icalendar::Values::DateTime.new start_time, 'tzid' => tzid
          e.dtend   = Icalendar::Values::DateTime.new end_time, 'tzid' => tzid
          e.summary = course_label
          #e.description = "Have a long lunch meeting and decide nothing..."
          #e.organizer = "mailto:jsmith@example.com"
          #e.organizer = Icalendar::Values::CalAddress.new("mailto:jsmith@example.com", cn: 'John Smith')
        end
      end
    end
  end
end


end
