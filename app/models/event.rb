class Event
  attr_accessor :start_time, :end_time, :label
  def initialize(start_time:,end_time:,label:)
    @start_time = start_time
    @end_time = end_time
    @label = label
  end
  def self.from_date_strings(start_time_string:,end_time_string:,label:)
    Event.new(start_time: DateTime.parse(start_time_string),
      end_time: DateTime.parse(end_time_string),
      label: label)
  end
  def ==(other_event)
    @start_time == other_event.start_time &&
    @end_time == other_event.end_time &&
    @label == other_event.label
  end
end
