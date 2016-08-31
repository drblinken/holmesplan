Rails.application.routes.draw do
  get 'start_page/select'
  root 'start_page#select', as: "course_selection"

  get 'all', to: 'week#courses'
  get 'week/select'
  get 'default', to: 'week#default'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
