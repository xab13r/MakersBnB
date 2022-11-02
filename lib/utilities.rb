require 'rack'
require 'uri'

class Utilities
  def sanitize(input)
    Rack::Utils.escape_html(input)
  end

  def validate_email(email_address)
    regex = URI::MailTo::EMAIL_REGEXP
    regex.match?(email_address)
  end

  def validate_name(name)
    regex = /^[A-Za-z0-9]+(?:[ -][A-Za-z0-9]+)*$/
    regex.match?(name)
  end
end
