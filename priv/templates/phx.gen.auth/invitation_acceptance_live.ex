defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.InvitationAcceptance do
  use <%= inspect context.web_module %>, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Accept Invitation
        <:subtitle>
          Please set your password to accept the invitation.<br />
          You will be able to log in after setting your password.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="invitation_acceptance_form"
        phx-submit="change-password"
        phx-change="validate"
      >
        <.error :if={@form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:password]} type="password" label="Password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm password"
          required
        />
        <:actions>
          <.button phx-disable-with="Setting..." class="w-full">Accept Invitation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_<%= schema.singular %>_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{<%= schema.singular %>: <%= schema.singular %>} ->
          <%= inspect context.module %>.change_<%= schema.singular %>_password(<%= schema.singular %>)

        _ ->
          %{}
      end

    {:ok, assign(socket, form: to_form(form_source), as: "<%= schema.singular %>")}
    # {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  def handle_event("validate", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    changeset = <%= inspect context.module %>.change_<%= schema.singular %>_password(socket.assigns.<%= schema.singular %>, <%= schema.singular %>_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("change-password", %{"<%= schema.singular %>" => <%= schema.singular %>_params}, socket) do
    case <%= inspect context.module %>.reset_<%= schema.singular %>_password(socket.assigns.<%= schema.singular %>, <%= schema.singular %>_params) do
      {:ok, _} ->
        {:noreply,
         put_flash(socket, :info, "Password changed successfully")
         |> redirect(to: ~p"<%= schema.route_prefix %>/log-in")}

      {:error, changeset} ->
        {:noreply,
         put_flash(socket, :error, "Error accepting invitation")
         |> assign(:form, to_form(changeset, as: :<%= schema.singular %>))}
    end
  end

  defp assign_<%= schema.singular %>_and_token(socket, %{"token" => token}) do
    if <%= schema.singular %> = <%= inspect context.module %>.get_<%= schema.singular %>_by_invite_<%= schema.singular %>_token(token) do
      assign(socket, <%= schema.singular %>: <%= schema.singular %>, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "<%= schema.singular %>"))
  end
end
