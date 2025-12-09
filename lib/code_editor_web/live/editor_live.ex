defmodule CodeEditorWeb.EditorLive do
  use CodeEditorWeb, :live_view
  alias CodeEditor.GitHub

  @interval 10_000

  def mount(_, _, socket) do
    if connected?(socket), do: :timer.send_interval(@interval, :poll)

    {:ok,
     assign(socket,
       repo: "",
       branch: "main",
       path: "",
       content: "",
       sha: "",
       dirty: false,
       status: "Idle"
     )}
  end

  def render(assigns) do
    ~H"""
      <div class="min-h-screen bg-gray-100 p-8">
      <div class="max-w-5xl mx-auto bg-white shadow-xl rounded-lg p-6">
        <h1 class="text-2xl text-gray-600 font-bold mb-4">🔥 GitHub Live Code Editor</h1>

        <!-- Form for repo/branch/path -->
        <form phx-change="update_inputs" phx-submit="fetch" class="space-y-4">

          <div class="grid grid-cols-3 gap-4">
            <input
              name="repo"
              value={@repo}
              placeholder="owner/repo"
              class="border p-2 rounded text-gray-600"
            />
            <input
              name="branch"
              value={@branch}
              placeholder="branch"
              class="border p-2 rounded text-gray-600"
            />
            <input
              name="path"
              value={@path}
              placeholder="file path"
              class="border p-2 rounded text-gray-600"
            />
          </div>

          <!-- Buttons and status -->
          <div class="flex items-center gap-4">
            <button type="submit" class="bg-black text-white px-5 py-2 rounded">Fetch</button>
            <button type="button" phx-click="save" class="bg-blue-600 text-white px-5 py-2 rounded">Save</button>
            <div class="text-sm text-gray-600 mt-2"><%= @status %></div>
            <div class="text-sm text-gray-600 mt-2">Dirty State: <%= @dirty %></div>
          </div>
        </form>

         <!-- ✅ TEXTAREA OUTSIDE THE FORM -->
    <div class="mt-6">
    <form phx-change="edit">
      <textarea
        name="content"
        value={@content}
        phx-input="edit"
        phx-debounce="200"
        rows="20"
        class="w-full border p-4 rounded font-mono text-gray-600 text-sm"
      >{@content}</textarea>
    </form>
    </div>
      </div>
    </div>

    """
  end

  def handle_event("update_inputs", %{"repo" => repo, "branch" => branch, "path" => path}, socket) do
    {:noreply, assign(socket, repo: repo, branch: branch, path: path)}
  end

# fetch file
def handle_event("fetch", _params, socket) do
  case CodeEditor.GitHub.fetch_file(socket.assigns.repo, socket.assigns.branch, socket.assigns.path) do
    {:ok, content, sha} ->
      {:noreply, assign(socket, content: content, sha: sha, dirty: false, status: "✅ File Loaded")}
    {:error, msg} ->
      {:noreply, assign(socket, status: msg)}
  end
end

# save file
def handle_event("save", _params, socket) do
  case CodeEditor.GitHub.update_file(socket.assigns.repo, socket.assigns.branch, socket.assigns.path, socket.assigns.content, socket.assigns.sha) do
    {:ok, sha} ->
      {:noreply, assign(socket, sha: sha, dirty: false, status: "✅ File Saved")}
    {:error, msg} ->
      {:noreply, assign(socket, status: msg)}
  end
end

# live typing in textarea
def handle_event("edit", %{"content" => content}, socket) do
  IO.inspect("User Editing")
  {:noreply, assign(socket, content: content, dirty: true)}
end


def parse_content(text) when is_binary(text) do
  text
  |> String.trim()
  |> String.split("\n", trim: true)
end


  def handle_info(:poll, socket) do
    IO.inspect("Poll Running")
    if socket.assigns.dirty != true do
      if socket.assigns.repo != "" and socket.assigns.path != "" do
        case CodeEditor.GitHub.fetch_file(socket.assigns.repo, socket.assigns.branch, socket.assigns.path) do
          {:ok, content, sha} ->
              if sha != socket.assigns.sha do
                {:noreply, assign(socket, content: content, sha: sha, status: "🔄 Remote updated!")}
              else
                {:noreply, socket}
              end
          {:error, msg} ->
              {:noreply, assign(socket, status: msg)}
        end
      else
        {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end
end
