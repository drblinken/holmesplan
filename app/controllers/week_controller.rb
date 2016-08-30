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

    course_plan.parse_calendar(cal,tzid,logger)
    3.times do
      next_url = "#{url}#{course_plan.next_day_id}"
      logger.debug "+++ next_url #{next_url}"
      course_plan = CoursePlan.new(next_url)
      course_plan.parse_calendar(cal,tzid,logger)
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






end
