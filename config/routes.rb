# Automatically listen to requests to /up and /up/:check without a typical
# mount Easymon::Engine => "/up" call in the host application
Easymon::Engine.routes.draw do
  root to: "checks#index"
  get ":check", to: "checks#show"
end