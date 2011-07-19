class Mechanize
  # this is an extended method to rebuild the browser state from the database
  def rebuild_page(url, cookie_jar, body)
    # cookie jar is assumed to be serialized into YAML
    self.cookie_jar = YAML.load(cookie_jar)
    
    p = Mechanize::Page.new(URI.parse(url), {'content-type' => 'text/html'}, body, 200, self)
    
    add_to_history(p)
  end
end