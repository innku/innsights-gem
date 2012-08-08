Dummy::Application.routes.draw do
  resources :dudes, only: [:index, :new]
end
