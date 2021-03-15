require 'spec_helper'
require 'proofer'
require 'lexisnexis'

RSpec.describe 'LexisNexis' do
  let(:config) do
    {
      base_url: base_url,
      request_mode: 'testing',
      account_id: 'test_account',
      username: 'test_username',
      password: 'test_password',
      instant_verify_workflow: 'customers.gsa.instant.verify.workflow',
      phone_finder_workflow: 'customers.gsa.phonefinder.workflow',
    }
  end

  describe 'InstantVerify' do
    subject(:proofer) do
      LexisNexis::InstantVerify::Proofer.new(**config)
    end

    it 'serves responses the proofer accepts' do
      response = proofer.proof(
        first_name: 'aaa',
        last_name: 'aaa',
        uuid: '1234',
        dob: '01/01/1970',
        ssn: '123456789',
        address1: '123 Fake St',
        city: 'Anycity',
        state: 'DC',
        zipcode: '12345'
      )

      expect(response.exception).to be_nil
      expect(response.success?).to eq(true)
    end
  end

  describe 'PhoneFinder' do
    subject(:proofer) do
      LexisNexis::PhoneFinder::Proofer.new(**config)
    end

    it 'serves responses the proofer accepts' do
      response = proofer.proof(
        first_name: 'aaa',
        last_name: 'aaa',
        uuid: '1234',
        phone: '+18885551234',
        dob: '01/01/1970',
        ssn: '123456789',
      )

      expect(response.exception).to be_nil
      expect(response.success?).to eq(true)
    end
  end
end
