require 'nokogiri'
require 'sinatra'
require 'json'
require 'securerandom'
require 'prometheus/client'
if ENV['NEW_RELIC_LICENSE_KEY'] && ENV['NEW_RELIC_APP_NAME']
  require 'newrelic_rpm'
  puts 'enabling newrelic'
end


module LoginGov
  class FakeVendorServer < Sinatra::Base

    # Prometheus init
    prometheus = Prometheus::Client.registry
    http_connections = Prometheus::Client::Gauge.new(:http_connections, docstring: 'current HTTP connections')
    prometheus.register(http_connections)
    http_connections.set(0)

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

    # LexisNexis TrueID
    post '/restws/identity/v3/accounts/:account_number/workflows/:workflow_name/conversations' do
      case params[:workflow_name]
      when /TrueID/
        sleep ENV['LEXISNEXIS_TRUE_ID_DELAY'].to_f
        fixture 'lexisnexis/true_id_response.json'
      end
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

    # USPS IPPaaS auth
    post "/oauth/authenticate" do
      sleep ENV['USPS_IPPAAS_AUTH_DELAY'].to_f
      content_type 'application/json'
      fixture 'usps/ippaas_oauth_authenticate_response.json'
    end

    # USPS IPPaaS
    post "/ivs-ippaas-api/IPPRest/resources/rest/getProofingResults" do
      sleep ENV['USPS_IPPAAS_GETPROOFINGRESULTS_DELAY'].to_f
      case ENV['USPS_IPPAAS_GETPROOFINGRESULTS_OUTCOME']
      when "missing_enrollment_code"
        status 400
        content_type 'application/json'
        fixture 'usps/ippaas_getproofingresults_missingenrollmentcode_response.json'
      else
        content_type 'application/json'
        fixture 'usps/ippaas_getproofingresults_response.json'
      end
    end

    # USPS IPPaaS
    post "/ivs-ippaas-api/IPPRest/resources/rest/optInIPPApplicant" do
      sleep ENV['USPS_IPPAAS_OPTINIPPAPPLICANT_DELAY'].to_f
      content_type 'application/json'
      fixture 'usps/ippaas_optinippapplicant_response.json'
    end

    # health
    get '/health' do
      begin
        sockstatdata = File.read('/proc/net/sockstat')
        connections = /TCP: inuse (?<inuse>\d+) /.match(sockstatdata)[:inuse].to_i
        http_connections.set(connections)
      rescue
        http_connections.set(1)
      end
      status 200
    end
  end

  class HandleBadEncodingMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
      rescue Rack::Utils::InvalidParameterError
        env['QUERY_STRING'] = ''
      end

      @app.call(env)
    end
  end
end
