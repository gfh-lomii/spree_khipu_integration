Spree::Core::Engine.routes.draw do
  post '/khipu/notify', to: 'khipu#notify'
end
