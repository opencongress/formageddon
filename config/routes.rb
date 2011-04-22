Rails.application.routes.draw do
  scope :module => 'formageddon', :as => 'formageddon' do    
    resources :formageddon_threads, :controller => 'threads', :path => '/formageddon/threads'
    resources :formageddon_contact_steps, :controller => 'contact_steps', :path => '/formageddon/contact_steps'
  end
end