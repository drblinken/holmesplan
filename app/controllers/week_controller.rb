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

    parse_calendar(course_plan,cal,tzid)
    3.times do
      next_url = "#{url}#{course_plan.next_day_id}"
      logger.debug "+++ next_url #{next_url}"
      course_plan = CoursePlan.new(next_url)
      parse_calendar(course_plan,cal,tzid)
    end
    render plain: cal.to_ical
  end

private



def course_should_be_included(course_label)
  ignore = ["Kids Swim", "Jumpin", "BODYPUMP", "Boxin", "Krav", "Body Shape",
  "BODYBALANCE","Les Mills","Zumba","Indoor Cyclin","Ballet","Cardio Workou",
  "Step","bodyART","Tabata","deepWork","Cross Train", "Capo Fit"]
  ignore.none?{|i| Regexp.new(i).match(course_label)}
end



def parse_calendar(course_plan,cal,tzid)
  doc = course_plan.doc
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
        time, duration = course_plan.parse_time_and_duration(time_and_duration)
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
