# identity-fake-vendor

A simple sinatra server that imitates our vendors. The client code to talk to them is in:

- [identity-aamva-api-client-gem](https://github.com/18F/identity-aamva-api-client-gem)
- [identity-lexisnexis-api-client-gem](http://github.com/18f/identity-lexisnexis-api-client-gem/)
- [https://github.com/18F/identity-doc-auth](https://github.com/18F/identity-doc-auth)

## Run the server

```bash
make run
```

### Tests

```bash
make test
```

### Configuring the Fake Server

Set these environment variables to configure the delay duration for the various actions:

```bash
AAMVA_SECURITY_TOKEN_DELAY=5
AAMVA_AUTHENTICATION_TOKEN_DELAY=5
AAMVA_VERIFICATION_DELAY=5
ACUANT_CREATE_DOCUMENT_DELAY=5
ACUANT_UPLOAD_IMAGE_DELAY=5
ACUANT_FACEMATCH_DELAY=5
ACUANT_GET_RESULTS_DELAY=5
LEXISNEXIS_INSTANT_VERIFY_DELAY=5
LEXISNEXIS_PHONE_FINDER_DELAY=5
```

### Configuring the IDP

Replace `$base_url` with the protocol, host, port (if needed):

```yaml
aamva_auth_request_timeout: "50"
aamva_verification_request_timeout: "50"
aamva_auth_url: "$base_url/Authentication/Authenticate.svc"
aamva_verification_url: "$base_url/dldv/2.1/online"

lexisnexis_base_url: "$base_url"
lexisnexis_instant_verify_workflow: "customers.gsa.instant.verify.workflow"
lexisnexis_phone_finder_workflow: "customers.gsa.phonefinder.workflow"
lexisnexis_timeout: "50"

acuant_timeout: "55"
acuant_assure_id_url: "$base_url"
acuant_facial_match_url: "$base_url"
doc_auth_vendor: 'acuant'
```
