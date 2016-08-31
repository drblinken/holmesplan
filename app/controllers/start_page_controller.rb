class StartPageController < ApplicationController
  def select
    course_plan = CoursePlan.new
    @course_labels = course_plan.all_course_labels
  end
end
