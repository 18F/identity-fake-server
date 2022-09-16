require 'nokogiri'
require 'sinatra'
require 'json'
require 'securerandom'

module LoginGov
  class FakeVendorServer < Sinatra::Base
    def fixture(path)
      File.read(File.join(__dir__, 'fixtures', path))
    end

    set :logging, true
    set :dump_errors, true
    set :raise_errors, true
    set :show_exceptions, :after_handler

    # AAMVA
    post '/Authentication/Authenticate.svc' do
      doc = Nokogiri::XML(request.body.read)
      action = doc.at_xpath('//ns:Action', ns: 'http://www.w3.org/2005/08/addressing').text

      case action
      when 'http://schemas.xmlsoap.org/ws/2005/02/trust/RST/SCT'
        sleep ENV['AAMVA_SECURITY_TOKEN_DELAY'].to_f
        fixture 'aamva/security_token_response.xml'
      when 'http://aamva.org/authentication/3.1.0/IAuthenticationService/Authenticate'
        sleep ENV['AAMVA_AUTHENTICATION_TOKEN_DELAY'].to_f
        fixture 'aamva/authentication_token_response.xml'
      end
    end

    # AAMVA
    post '/dldv/2.1/online' do
      sleep ENV['AAMVA_VERIFICATION_DELAY'].to_f
      fixture 'aamva/verification_response.xml'
    end

    # Acuant
    post '/AssureIDService/Document/Instance' do
      sleep ENV['ACUANT_CREATE_DOCUMENT_DELAY'].to_f
      # body is a JSON atom
      SecureRandom.hex.to_json
    end

    # Acuant
    post '/AssureIDService/Document/:instance_id/Image' do
      ''
    end

    # The way the Acuant Client encodes images does not play well with sinatra's parameter parsing
    error Sinatra::BadRequest do
      sleep ENV['ACUANT_UPLOAD_IMAGE_DELAY'].to_f
      status 200
      ''
    end

    # Acuant
    post '/api/v1/facematch' do
      sleep ENV['ACUANT_FACEMATCH_DELAY'].to_f
      fixture 'acuant/facial_match_response.json'
    end

    # Acuant
    get '/AssureIDService/Document/:instance_id' do
      sleep ENV['ACUANT_GET_RESULTS_DELAY'].to_f
      fixture 'acuant/get_results_response.json'
    end

    # LexisNexis
    post "/restws/identity/v2/:account_number/:workflow_name/conversation" do
      case params[:workflow_name]
      when /instant.verify/
        sleep ENV['LEXISNEXIS_INSTANT_VERIFY_DELAY'].to_f
        fixture 'lexisnexis/instant_verify_response.json'
      when /phonefinder/
        sleep ENV['LEXISNEXIS_PHONE_FINDER_DELAY'].to_f
        fixture 'lexisnexis/phone_finder_response.json'
      end
    end

    # USPS
    post '/ivs-ippaas-api/IPPRest/resources/rest/optInIPPApplicant' do
      fixture 'usps/request_enroll_response.json'
    end

    # USPS
    post '/ivs-ippaas-api/IPPRest/resources/rest/getProofingResults' do
      fixture 'usps/request_passed_proofing_results_response.json'
    end

    # USPS
    post '/ivs-ippaas-api/IPPRest/resources/rest/requestEnrollmentCode' do
      fixture 'usps/request_enrollment_code_response.json'
    end

    # USPS
    post '/oauth/authenticate' do
      fixture 'usps/request_token_response.json'
    end
  end
end
