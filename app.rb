require 'sinatra'
require 'nokogiri'

module LoginGov
  class FakeVendorServer < Sinatra::Base
    def fixture(path)
      File.read(File.join(__dir__, 'fixtures', path))
    end

    # AAMVA
    post '/Authentication/Authenticate.svc' do
      doc = Nokogiri::XML(request.body.read)
      action = doc.at_xpath('//ns:Action', ns: 'http://www.w3.org/2005/08/addressing').text

      case action
      when 'http://schemas.xmlsoap.org/ws/2005/02/trust/RST/SCT'
        fixture 'aamva/security_token_response.xml'
      when 'http://aamva.org/authentication/3.1.0/IAuthenticationService/Authenticate'
        fixture 'aamva/authentication_token_response.xml'
      end
    end

    # AAMVA
    post '/dldv/2.1/online' do
      fixture 'aamva/verification_response.xml'
    end

    # LexisNexis
    post "/restws/identity/v2/:account_number/:workflow_name/conversation" do
      case params[:workflow_name]
      when /instant.verify/
        fixture 'lexisnexis/instant_verify_response.json'
      when /phonefinder/
        fixture 'lexisnexis/phone_finder_response.json'
      end
    end
  end
end
