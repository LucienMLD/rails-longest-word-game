Rails.application.routes.draw do
  get "/"   => "game#game"
  get "/score"  => "game#score"
end
