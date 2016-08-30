class Event
  attr_accessor :start_time, :end_time, :label
  def initialize(start_time:,end_time:,label:)
    @start_time = start_time
    @end_time = end_time
    @label = label
  end
end
