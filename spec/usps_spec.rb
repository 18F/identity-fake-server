require 'spec_helper'
require 'faraday'

RSpec.describe 'USPS IPPaaS' do
    let(:client) do
        Faraday.new(
            url: base_url,
            headers: {
                'Content-Type': 'application/json',
            },
        )
    end
    describe 'auth' do
        it 'serves a successful response' do
            response = client.post('/oauth/authenticate') do |req|
                req.body = {
                    "username" => "testuser",
                    "password" => "testpassword",
                    "grant_type" => "implicit",
                    "response_type" => "token",
                    "client_id" => "7e2024b0-37d3-013b-7671-2cde48001122",
                    "scope" => "ivs.ippaas.apis",
                }.to_json
            end

            expect(response.status).to be(200)
            expect(response.headers&.[]('Content-Type')).to eq('application/json')
            expect(JSON.parse(response.body)).to include(
                "token_type" => "Bearer",
                "access_token" => "COYR+QInVfXtM8qC+UdBlTnUFBC10AK/ ",
                "expires_in" => 86400,
                "refresh_token" => " AXoBH8hrJfWKNfx6cUuQD5MKU9nNIHaDIFyGBv",
            )
        end
    end

    describe 'getProofingResults' do
        original_outcome = nil

        before do
            original_outcome = ENV['USPS_IPPAAS_GETPROOFINGRESULTS_OUTCOME']
        end

        after do
            ENV['USPS_IPPAAS_GETPROOFINGRESULTS_OUTCOME'] = original_outcome
        end
        
        it 'can serve a successful response' do
            response = client.post('/ivs-ippaas-api/IPPRest/resources/rest/getProofingResults') do |req|
                req.headers['RequestID'] = '13ca7b60-37d4-013b-7672-2cde48001122'
                req.headers['Authorization'] = 'Bearer COYR+QInVfXtM8qC+UdBlTnUFBC10AK/ '
                req.body = {
                    "sponsorID" => 4,
                    "uniqueID" => 32432,
                    "enrollmentCode" => "3438274832758323",
                }.to_json
            end

            expect(response.status).to be(200)
            expect(response.headers&.[]('Content-Type')).to eq('application/json')
            expect(JSON.parse(response.body)).to include(
                "status" => "In-person passed",
                "proofingPostOffice" => "WILKES BARRE",
                "proofingCity" => "WILKES BARRE",
                "proofingState" => "PA",
                "enrollmentCode" => "2090002197504352",
                "primaryIdType" => "State driver's license",
                "transactionStartDateTime" => "12/17/2020 033855",
                "transactionEndDateTime" => "12/17/2020 034055",
                "fraudSuspected" => false,
                "proofingConfirmationNumber" => "350040248346701",
                "ippAssuranceLevel" => "1.5"
            )
        end

        it 'can serve a bad request response' do
            ENV['USPS_IPPAAS_GETPROOFINGRESULTS_OUTCOME'] = 'missing_enrollment_code'

            response = client.post('/ivs-ippaas-api/IPPRest/resources/rest/getProofingResults') do |req|
                req.headers['RequestID'] = '13ca7b60-37d4-013b-7672-2cde48001122'
                req.headers['Authorization'] = 'Bearer COYR+QInVfXtM8qC+UdBlTnUFBC10AK/ '
                req.body = {
                    "sponsorID" => 4,
                    "uniqueID" => 32432,
                    "enrollmentCode" => "3438274832758323",
                }.to_json
            end

            expect(response.status).to be(400)
            expect(response.headers&.[]('Content-Type')).to eq('application/json')
            expect(JSON.parse(response.body)).to include(
                "responseMessage" => "Enrollment code 3438274832758323 does not exist"
            )
        end
    end
end