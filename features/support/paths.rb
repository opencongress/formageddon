module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the test app index page/
      '/'
    
    when /login/
      '/users/sign_in'
    
    when /the admin new contact steps page/
      '/formageddon/contact_steps/new?recipient_id=55&recipient_type=SomeClass'
    
    ## the following are test form pages
    when /no forms/
      "visit::http://www.example.com/no_form"
    when /one form/
      "visit::http://www.example.com/1_form"
    when /two forms/
      "visit::http://www.example.com/2_form"
      
    when /the (.*) test page/
      components_path(:component => $1)

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)