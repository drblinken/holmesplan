class WeekController < ApplicationController


  def courses
    require 'icalendar/tzinfo'

    cal = Icalendar::Calendar.new
    tzid = 'Europe/Berlin'
    tz = TZInfo::Timezone.get tzid

    event_start = DateTime.new(2016,8,30,9,0,0)
    timezone = tz.ical_timezone event_start
    cal.add_timezone timezone

    course_plan = CoursePlan.new
    doc = course_plan.doc
    url = CoursePlan.url

    parse_calendar(doc,cal,tzid)
    2.times do
      next_id = parse_next_day(doc)
      next_url = "#{url}#{next_id}"

      doc = Nokogiri::HTML(open(next_url))
      parse_calendar(doc,cal,tzid)
      logger.debug "+++ next_url #{next_url}"
    end
    render plain: cal.to_ical
  end

private

def parse_time_and_duration(time_and_duration)
  match = /(.*) \| (\d?\d\d)'/.match(time_and_duration)
  logger.debug "++++ Could not be parsed: #{time_and_duration}" unless match
  start_time = match[1]
  minutes = match[2] ? match[2].to_i : 0
  logger.debug "++++ Duration not found" unless match[2]
  return start_time, minutes
end

def course_should_be_included(course_label)
  ignore = ["Kids Swim", "Jumpin", "BODYPUMP", "Boxin", "Krav", "Body Shape",
  "BODYBALANCE","Les Mills","Zumba","Indoor Cyclin","Ballet","Cardio Workou",
  "Step","bodyART","Tabata","deepWork","Cross Train", "Capo Fit"]
  ignore.none?{|i| Regexp.new(i).match(course_label)}
end

def parse_next_day(doc)
  element = doc.css("div.headerNextDay")
  nextdayid = element.attribute("data-next-day").value
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
    logger.debug "date #{date}"
    dates << Date.parse(date)
    date_strings << "#{date} #{year}"
    logger.debug "day: #{day} date: #{date}"
  end

  logger.debug dates.inspect
  logger.debug date_strings.inspect

  #blocks = "div.mor".split
  #blocks = "div.aft".split
  blocks = "div.nig".split
  blocks = "div.mor, div.aft, div.nig".split(",")
  logger.debug "blocks: #{blocks}"
  blocks.each do |block_selector|
    logger.debug "++++ Starting on block #{block_selector}"
    block = doc.css(block_selector)
    logger.debug "++++ this block has #{block.css("div.dayColumn").size} days"
    day = -1
    block.css("div.dayColumn").each do | dayColumn |
      day = day + 1
      logger.debug "DAY: #{dates[day]}"
      dayColumn.css()
      #logger.debug dayColumn.class
      dayColumn.css("div.timetableProgram").each do |course|
        spans = course.css("span")
        time_and_duration = spans[0].text
        time, duration = parse_time_and_duration(time_and_duration)
        logger.debug "time #{time_and_duration}"
        start_time = DateTime.parse("#{date_strings[day]} #{time_and_duration}")
        end_time = start_time + (duration/1440.0)
        logger.debug "start_time: #{start_time.inspect}"
        logger.debug "end_time:   #{end_time.inspect}"
        course_label = course.css("span.timetableProgramLabel").text
        logger.debug "course #{course_label}"
        if course_should_be_included(course_label)
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


end
