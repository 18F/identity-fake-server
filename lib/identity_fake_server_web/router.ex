defmodule IdentityFakeServerWeb.Router do
  use IdentityFakeServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IdentityFakeServerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IdentityFakeServerWeb do
    post "/Authentication/Authenticate.svc", PageController, :aamva_auth
    post "/dldv/2.1/online", PageController, :aamva_verification
    post "/AssureIDService/Document/Instance", PageController, :acuant_document
    post "/AssureIDService/Document/:instance_id/Image", PageController, :acuant_document_image
    get "/AssureIDService/Document/:instance_id", PageController, :acuant_results

    post "/restws/identity/v3/accounts/:account_number/workflows/:workflow_name/conversations",
         PageController,
         :lexis_nexis_true_id

    post "/restws/identity/v2/:account_number/:workflow_name/conversation",
         PageController,
         :instant_verify_phone_finder

    post "/oauth/authenticate", PageController, :usps_auth

    post "/ivs-ippaas-api/IPPRest/resources/rest/getProofingResults",
         PageController,
         :usps_results

    get "/health", PageController, :health
  end

  # Other scopes may use custom stacks.
  # scope "/api", IdentityFakeServerWeb do
  #   pipe_through :api
  # end
end
