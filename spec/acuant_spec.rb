require 'spec_helper'
require 'proofer'
require 'identity-doc-auth'

RSpec.describe 'Acuant' do
  subject(:client) do
    IdentityDocAuth::Acuant::AcuantClient.new(
      assure_id_url: base_url,
      facial_match_url: base_url,
      passlive_url: base_url,
      timeout: 55,
    )
  end

  it 'serves responses the proofer accepts' do
    response = client.post_images(
      front_image: SecureRandom.random_bytes,
      back_image: SecureRandom.random_bytes,
      selfie_image: SecureRandom.random_bytes,
    )

    expect(response.exception).to be_nil
    expect(response.success?).to eq(true)
  end
end
