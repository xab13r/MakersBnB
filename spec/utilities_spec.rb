require "spec_helper"
require 'utilities'

describe Utilities do
  
  let(:utils) { Utilities.new}
  
  describe "#sanitize" do
    it "escapes html from user input" do
      
      #utilities = Utilities.new
      string = "<script>window.alert(\"You've been p0wn3d!!!!\"); document.location.href=\"https://www.youtube.com/watch?v=34Ig3X59_qA\";</script>"
      
      output = '&lt;script&gt;window.alert(&quot;You&#x27;ve been p0wn3d!!!!&quot;); document.location.href=&quot;https:&#x2F;&#x2F;www.youtube.com&#x2F;watch?v=34Ig3X59_qA&quot;;&lt;&#x2F;script&gt;'
      
      expect(utils.sanitize(string)).to eq output
    end
  end
  
  describe "#validate_email" do
    it "returns true if the email doesn't include invalid characters" do
      email = 'email@email.com'
      
      output = utils.validate_email(email)
      
      expect(output).to eq true
    end
    
    it "returns false if the email includes invalid characters" do
      email = 'email@@email.com'
      
      output = utils.validate_email(email)
      
      expect(output).to eq false
    end
  end
  
  describe "#validate_name" do
    it "returns true if the name doesn't include invalid characters" do
      name = 'This Is a Valid-Name'
      output = utils.validate_name(name)
      
      expect(output).to eq true
    end
    
    it "returns false if the name include invalid characters" do
      name = 'This Is a Not_Valid Name'
      output = utils.validate_name(name)
      
      expect(output).to eq false
    end
  end
end