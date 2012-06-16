Homlesslink::Application.routes.draw do

  resources :local_authorities, only: [:index]

end
