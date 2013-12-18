# use `mount Easymon::Engine => "/up"` in the host application routes.rb
Easymon::Engine.routes.draw do
  root to: "checks#index"
  get ":check", to: "checks#show"
end