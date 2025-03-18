defmodule IdentityFakeServerWeb.PageController do
  use IdentityFakeServerWeb, :controller
  import SweetXml

  def aamva_auth(conn, _params) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    IO.inspect(conn)

    action =
      SweetXml.parse(body)
      |> SweetXml.xpath(
        ~x"//Action/text()"
        |> SweetXml.add_namespace("ff", "http://www.w3.org/2005/08/addressing")
      )

    response_body =
      case action do
        ~c"http://schemas.xmlsoap.org/ws/2005/02/trust/RST/SCT" ->
          environment_variable_to_milliseconds_to_seconds("AAMVA_SECURITY_TOKEN_DELAY")
          |> Process.sleep()

          read_fixture_file!("aamva/security_token_response.xml")

        ~c"http://aamva.org/authentication/3.1.0/IAuthenticationService/Authenticate" ->
          environment_variable_to_milliseconds_to_seconds("AAMVA_AUTHENTICATION_TOKEN_DELAY")
          |> Process.sleep()

          read_fixture_file!("aamva/authentication_token_response.xml")
      end

    put_status(conn, 200)
    |> text(response_body)
  end

  def aamva_verification(conn, _params) do
    environment_variable_to_milliseconds_to_seconds("AAMVA_VERIFICATION_DELAY")
    |> Process.sleep()

    response_body = read_fixture_file!("aamva/verification_response.xml")

    put_status(conn, 200)
    |> text(response_body)
  end

  def acuant_document(conn, _params) do
    environment_variable_to_milliseconds_to_seconds("ACUANT_CREATE_DOCUMENT_DELAY")
    |> Process.sleep()

    response_body =
      :crypto.strong_rand_bytes(16)
      |> Base.encode16()
      |> String.downcase()
      |> JSON.encode!()

    put_status(conn, 200)
    |> text(response_body)
  end

  def acuant_document_image(conn, _params) do
    environment_variable_to_milliseconds_to_seconds("ACUANT_UPLOAD_IMAGE_DELAY")
    |> Process.sleep()

    put_status(conn, 200)
    |> text("")
  end

  def acuant_results(conn, _params) do
    environment_variable_to_milliseconds_to_seconds("ACUANT_GET_RESULTS_DELAY")
    |> Process.sleep()

    response_body = read_fixture_file!("acuant/get_results_response.json")

    put_status(conn, 200)
    |> text(response_body)
  end

  def lexis_nexis_true_id(conn, params) do
    workflow_name = Map.get(params, "workflow_name")

    cond do
      String.match?(workflow_name, ~r/TrueID/) ->
        environment_variable_to_milliseconds_to_seconds("LEXISNEXIS_TRUE_ID_DELAY")
        |> Process.sleep()

        put_status(conn, 200)
        |> text(read_fixture_file!("lexisnexis/true_id_response.json"))
    end
  end

  def instant_verify_phone_finder(conn, params) do
    workflow_name = Map.get(params, "workflow_name")

    cond do
      String.match?(workflow_name, ~r/instant.verify/) ->
        environment_variable_to_milliseconds_to_seconds("LEXISNEXIS_INSTANT_VERIFY_DELAY")
        |> Process.sleep()

        put_status(conn, 200)
        |> text(read_fixture_file!("acuant/get_results_response.json"))

      String.match?(workflow_name, ~r/phonefinder/) ->
        environment_variable_to_milliseconds_to_seconds("LEXISNEXIS_PHONE_FINDER_DELAY")
        |> Process.sleep()

        put_status(conn, 200)
        |> text(read_fixture_file!("acuant/get_results_response.json"))
    end
  end

  def usps_auth(conn, _params) do
  end

  def usps_results(conn, _params) do
  end

  def health(conn, _params) do
    put_status(conn, 200)
    |> json(%{status: "healthy"})
  end

  defp environment_variable_to_milliseconds_to_seconds(key) when is_binary(key) do
    (System.get_env(key) || "0")
    |> String.to_integer()
    |> Kernel.*(1000)
  end

  defp read_fixture_file!(file_path) do
    Application.app_dir(:identity_fake_server)
    |> Path.join("priv/static/fixtures")
    |> Path.join(file_path)
    |> File.read!()
  end
end
