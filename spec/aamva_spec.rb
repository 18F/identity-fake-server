require 'spec_helper'
require 'proofer'
require 'aamva'
require 'openssl'
require 'base64'
require 'time'

RSpec.describe 'AAMVA' do
  let(:proofer) do
    private_key, public_key = certs

    Aamva::Proofer.new(
      auth_url: "#{base_url}/Authentication/Authenticate.svc",
      verification_url: "#{base_url}/dldv/2.1/online",
      cert_enabled: 'false',
      private_key: Base64.encode64(private_key.to_der),
      public_key: Base64.encode64(public_key.to_der),
      auth_request_timeout: 50,
      verification_request_timeout: 50,
    )
  end

  it 'serves requests that the AAMVA gem accepts' do
    response = proofer.proof(
      first_name: 'aaa',
      last_name: 'bbb',
      uuid: '1234',
      state_id_number: 'aaaa',
      state_id_type: 'drivers_license',
      state_id_jurisdiction: 'DC',
      dob: '01/01/1970'
    )

    expect(response.exception).to be_nil
    expect(response.success?).to eq(true)
  end

  # @return [Array(OpenSSL::PKey::RSA, OpenSSL::X509::Certificate)]
  def certs
    private_key = OpenSSL::PKey::RSA.new(2048)

    current_time = Time.now
    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse('/C=BE/O=Test/OU=Test/CN=Test')
    cert.not_before = current_time
    cert.not_after = current_time + 365 * 24 * 60 * 60
    cert.public_key = private_key.public_key
    cert.serial = 0x0
    cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.extensions = [
      ef.create_extension('basicConstraints', 'CA:TRUE', true),
      ef.create_extension('subjectKeyIdentifier', 'hash'),
    ]
    cert.add_extension ef.create_extension('authorityKeyIdentifier',
                                           'keyid:always,issuer:always')

    cert.sign(private_key, OpenSSL::Digest::SHA256.new)

    [private_key, cert]
  end
end
