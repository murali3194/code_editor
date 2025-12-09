defmodule CodeEditor.GitHub do
  @moduledoc "GitHub API client using runtime Tesla configuration"


  @base_url "https://api.github.com"

  defp client do
    token = System.get_env("GITHUB_TOKEN")
    if is_nil(token) do
      {:error, :missing_token}
    else
       middleware = [
        {Tesla.Middleware.BaseUrl, @base_url},
        Tesla.Middleware.JSON,
        {Tesla.Middleware.Headers, [
          {"authorization", "Bearer #{token}"},
          {"accept", "application/vnd.github+json"},
          {"user-agent", "phoenix-code-editor"}
        ]},
        {Tesla.Middleware.Timeout, timeout: 30_000}
      ]
       adapter = {Tesla.Adapter.Mint, timeout: 30_000}
      # Return Tesla client struct
      Tesla.client(middleware, adapter)
    end
  end


  # FETCH FILE
  def fetch_file(repo, branch, path) do
    case client() do
      {:error, :missing_token} ->
        {:error, "GitHub token missing"}

      client ->
        url = "/repos/#{repo}/contents/#{path}?ref=#{branch}"

        # Tesla returns %Tesla.Env{} directly
        resp = Tesla.get!(client, url)

        if resp.status == 200 do
          content = resp.body["content"]
          |> String.replace("\n", "")   # remove newlines
          |> Base.decode64!()

          {:ok, content, resp.body["sha"]}
        else
          {:error, "HTTP error: #{resp.status}"}
        end
    end
  end




  # UPDATE FILE
  def update_file(repo, branch, path, content, sha) do
    body = %{
      "message" => "Update via LiveView",
      "content" => Base.encode64(content),
      "sha" => sha,
      "branch" => branch
    }

    case Tesla.put(client(), "/repos/#{repo}/contents/#{path}", body) do
      {:ok, %{status: s, body: body}} when s in 200..201 ->
        {:ok, body["content"]["sha"]}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
