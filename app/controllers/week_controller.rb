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

    events = course_plan.parse_calendar(cal,tzid,logger)
    1.times do
      next_url = "#{url}#{course_plan.next_day_id}"
      logger.debug "+++ next_url #{next_url}"
      course_plan = CoursePlan.new(next_url)
      events.concat(course_plan.parse_calendar(cal,tzid,logger))
    end

    events.flatten!
    
    events.each do | event |
      logger.debug "EVENT:   "+event.inspect
      if course_should_be_included(event.label)
        cal.event do |e|
          e.dtstart = Icalendar::Values::DateTime.new event.start_time, 'tzid' => tzid
          e.dtend   = Icalendar::Values::DateTime.new event.end_time, 'tzid' => tzid
          e.summary = event.label
        end
      end
    end
    render plain: cal.to_ical
  end

  def course_should_be_included(course_label)
    ignore = ["Kids Swim", "Jumpin", "BODYPUMP", "Boxin", "Krav", "Body Shape",
    "BODYBALANCE","Les Mills","Zumba","Indoor Cyclin","Ballet","Cardio Workou",
    "Step","bodyART","Tabata","deepWork","Cross Train", "Capo Fit"]
    ignore.none?{|i| Regexp.new(i).match(course_label)}
  end

end
