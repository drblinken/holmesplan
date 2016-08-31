class WeekController < ApplicationController

  def select
    include_or_exclude = request.params["include_or_exclude"] 
    selected_labels = request.params["labels"] ? request.params["labels"]["selected"] : []
    include_labels = exclude_labels = nil
    if include_or_exclude == "include"
      include_labels = selected_labels
    else
      exclude_labels = selected_labels
    end
    
    cal = fill_calendar(include_labels,exclude_labels)
#{"utf8"=>"✓", "commit"=>"Get URL", "labels"=>{"include"=>["Schwimmtraini.", "Core Xpress", "Hatha Yoga"]}, "controller"=>"week", "action"=>"include"}
    render plain: cal.to_ical
  end

  def courses
    cal = fill_calendar(nil,["Kids Swim", "Jumpin", "BODYPUMP", "Boxin", "Krav", "Body Shape",
    "BODYBALANCE","Les Mills","Zumba","Indoor Cyclin","Ballet","Cardio Workou",
    "Step","bodyART","Tabata","deepWork","Cross Train", "Capo Fit"])
    render plain: cal.to_ical
  end


  def course_should_be_included(course_label,include_labels,exclude_labels)
   if include_labels
     include_labels.any?{|i| Regexp.new(i).match(course_label)}
   else 
     exclude_labels.none?{|i| Regexp.new(i).match(course_label)}
   end
  end
private 

  def fill_calendar(include_labels, exclude_labels)
    require 'icalendar/tzinfo'
    cal = Icalendar::Calendar.new
    tzid = 'Europe/Berlin'
    tz = TZInfo::Timezone.get tzid
    
    event_start = DateTime.new(2016,8,30,9,0,0)
    timezone = tz.ical_timezone event_start
    cal.add_timezone timezone
    
    course_plan = CoursePlan.new
    url = CoursePlan.url
    
    events = course_plan.parse_calendar
    0.times do
      next_url = "#{url}#{course_plan.next_day_id}"
      logger.debug "+++ next_url #{next_url}"
      course_plan = CoursePlan.new(next_url)
      events.concat(course_plan.parse_calendar)
    end
    
    events.flatten!
    
    events.each do | event |
      logger.debug "EVENT:   "+event.inspect
      if course_should_be_included(event.label,include_labels, exclude_labels)
        cal.event do |e|
          e.dtstart = Icalendar::Values::DateTime.new event.start_time, 'tzid' => tzid
          e.dtend   = Icalendar::Values::DateTime.new event.end_time, 'tzid' => tzid
          e.summary = event.label
        end
      end
    end
    cal
  end
  
end
