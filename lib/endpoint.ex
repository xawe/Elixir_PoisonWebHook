defmodule WebhookProcessor.Endpoint do
    @moduledoc """
    A Plug responsible for loggin request info, parsing request body´s as JSON,
    matchin routes, and dispatching responses.
    """

    use Plug.Router

    plug(Plug.Logger)

    plug(:match)

    plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

    plug(:dispatch)

    get "/ping" do
        send_resp(conn, 200, "pong!")
    end

    get "/test" do
        send_resp(conn, 200, "Teste ok :>>")
    end

    post "/events" do
        {status, body} =
            case conn.body.params do
                %{"events" => events} -> {200, process_events(events)}
                _ -> {422, missing_events()}
            end
        send_resp(conn, status, body)
    end

    defp process_events(events) when is_list(events) do
        Poison.encode!(%{response: "Received Events!"})
    end

    defp process_events(_) do
        Poison.encode!(%{response: "Please Send Some Events"})
    end

    defp missing_events do
        Poison.encode!(%{error: "Expected Payload: { 'events': [...]}"})
    end

    match _ do
        send_resp(conn, 404, "oops... Nothing Here :(")
    end

end

