defmodule RepeatReplyWeb.PageLive do
  use RepeatReplyWeb, :live_view

  defmodule PageComponent do
    use RepeatReplyWeb, :live_component

    def handle_event("request-data", _params, socket) do
      {:reply, %{data: DateTime.utc_now(), fatty: fatty(1024 * 100)}, socket}
    end

    # this event does nothing, the stale reply will be sent every time you trigger this.
    def handle_event("noop-event", _params, socket) do
      {:noreply, socket}
    end

    # this event does something, the reply will be repeated the first time, then
    # each other call will function correctly.
    def handle_event("op-event", _params, socket) do
      {:noreply, push_event(socket, "some-event", %{data: DateTime.utc_now()})}
    end

    def render(assigns) do
      ~H"""
      <div id="the-hook" phx-hook="MyHook" phx-target={@myself} class="space-y-4">
        <p>
          The hook will mount, tell the liveview its ready for data via
          `pushEventTo` and receive a message with some data.
        </p>
        <p>
          The hook received data: <code>null</code>
        </p>
        <p>
          As expected, the network traffic shows an update, with a `r` key
          containing the hook reply.
        </p>
        <div class="space-y-4 border-l-2 p-4">
          <p>
            This button triggers a no-op event, where handle_event returns
            `{:noreply, socket}`. This will cause the original reply to be
            re-sent each time.
          </p>
          <p>
            <button class="border p-1 bg-zinc-200" phx-click="noop-event" phx-target={@myself}>
              Send noop-event
            </button>
          </p>
        </div>
        <div class="space-y-4 border-l-2 p-4">
          <p>
            This button will send an event which returns `{:noreply, push_event(socket, ...)}`.
            The original reply will be repeated the first time, then only the
            new event data will be sent.
          </p>
          <p>
            <button class="border p-1 bg-zinc-200" phx-click="op-event" phx-target={@myself}>
              Send op-event
            </button>
          </p>
        </div>
      </div>
      """
    end

    # this bug is particularly painful if the data-response had a large payload
    # since its pushed down the wire twice.
    defp fatty(bytes) do
      :crypto.strong_rand_bytes(bytes)
      |> Base.encode64()
    end
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PageComponent} id="my_page_component" />
    """
  end
end
