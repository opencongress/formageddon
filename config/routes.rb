Rails.application.routes.draw do
  scope :module => 'formageddon', :as => 'formageddon' do    
    resources :formageddon_threads, :controller => 'threads', :path => '/formageddon/threads'
    resources :formageddon_contact_steps, :controller => 'contact_steps', :path => '/formageddon/contact_steps'
    resources :formageddon_delivery_attempts, :controller => 'delivery_attempts', :path => '/formageddon/delivery_attempts'
    resources :formageddon_forms, :controller => 'forms', :path => '/formageddon/forms'
    
    match 'captcha_image/:id' => 'formageddon/captcha_image#show'
  end
end