defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Invitation do
  use <%= inspect context.web_module %>, :live_view

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        New user invitation
        <:subtitle>
          Invite a new <%= schema.singular %> to the application.<br />
          They will receive an email with instructions to set their password.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="invitation_form" phx-submit="send_invite" phx-change="validate">
        <.input field={@form[:email]} type="email" label="New user email" required />

        <:actions>
          <.button phx-disable-with="Sending invite..." class="w-full">Send invite</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_invitation(%<%= inspect schema.alias %>{})
    socket =
      socket
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("send_invite", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    case <%= inspect context.alias %>.invite_<%= schema.singular %>(<%= schema.singular %>_params) do
      {:ok, <%= schema.singular %>} ->
        {:ok, _} =
          <%= inspect context.alias %>.deliver_<%= schema.singular %>_invitation_instructions(
            <%= schema.singular %>,
            socket.assigns.current_<%= schema.singular %>,
            &url(~p"<%= schema.route_prefix %>/accept-invitation/#{&1}")
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    changeset = <%= inspect context.alias %>.change_<%= schema.singular %>_invitation(%<%= inspect schema.alias %>{}, <%= schema.singular %>_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :vsalidate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "<%= schema.singular %>")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
