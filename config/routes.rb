Rails.application.routes.draw do
  get 'week/courses'
  root 'week#courses', as: "whole_plan"
  get 'week/include'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
