# Automatically listen to requests to /up and /up/:check without a typical
# mount Easymon::Engine => "/up" call in the host application
Rails.application.routes.draw do
  get "/up", to: "Easymon::checks#index"
  get "/up/:check", to: "Easymon::checks#show"
end