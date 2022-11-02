require 'rack'

class Utilities
  
  def sanitize(input)
    Rack::Utils.escape_html(input)
  end
end