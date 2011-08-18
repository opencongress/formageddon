module Formageddon
  class FormageddonDeliveryAttempt < ActiveRecord::Base
    belongs_to :formageddon_letter
    
    belongs_to :before_browser_state, :class_name => 'FormageddonBrowserState', :foreign_key => 'before_browser_state_id'
    belongs_to :after_browser_state, :class_name => 'FormageddonBrowserState', :foreign_key => 'after_browser_state_id'
    
    def save_before_browser_state(browser)
      state = before_browser_state
      if state.nil?
        state = create_before_browser_state
      end
      
      save_state(state, browser)
    end
    
    def save_after_browser_state(browser)
      state = after_browser_state
      if state.nil?
        state = create_after_browser_state
      end
      
      save_state(state, browser)
    end
    
    def save_state(state, browser)
      state.cookie_jar = YAML.dump(browser.cookie_jar)
      state.raw_html = Iconv.conv("UTF-8//IGNORE", "US-ASCII", browser.page.parser.to_s)
      state.uri = browser.page.uri.to_s
      
      state.save
    end
    
    def rebuild_browser(browser, before = true)
      state = before ? before_browser_state : after_browser_state
      return browser if state.nil?
      
      browser.rebuild_page(state.uri, state.cookie_jar, state.raw_html)

      browser
    end
    
    def to_s
      result
    end
  end
end