defmodule SlackCoder.Router do
  use SlackCoder.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Ueberauth
    plug SlackCoder.Guardian.Pipeline
  end

  pipeline :tools do
    plug :fetch_session
    plug Ueberauth
    plug SlackCoder.Guardian.Pipeline
  end

  pipeline :restricted do
    plug SlackCoder.Guardian.RestrictedPipeline
  end

  pipeline :admin do
    plug SlackCoder.Guardian.AdminPipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, module: SlackCoder.Guardian,
                                     error_handler: SlackCoder.Guardian.AuthErrorHandler
  end

  scope "/" do
    pipe_through :browser # Use the default browser stack

    for path <- ["/", "/mobile/login", "/users", "/login", "/user/:id/edit"] do
      get path, SlackCoder.PageController, :index
    end

    scope "/" do
      pipe_through :restricted

      # Moving to react soon
      get "/failure_logs/:id", SlackCoder.Web.RandomFailureController, :log

      scope "/admin" do
        pipe_through :admin

        scope "/", SlackCoder do
          # Need to either port or remove
          get "/messages", UserController, :messages
        end
      end
    end
  end

  # Admin tools
  scope "/tools" do
    pipe_through [:tools, :restricted, :admin]

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: SlackCoder.GraphQL.Schemas.MainSchema,
      default_headers: {__MODULE__, :graphiql_headers},
      default_url: "/api/graphql"

    forward "/wobserver", Wobserver.Web.Router
    forward "/errors", Flames.Web
  end

  scope "/api" do
    pipe_through :api

    post "/github/event", SlackCoder.GithubController, :event

    scope "/" do
      pipe_through :restricted

      forward "/graphql", Absinthe.Plug, schema: SlackCoder.GraphQL.Schemas.MainSchema

      get "/pull_requests/:owner/:repo/:pr/refresh", SlackCoder.PageController, :synchronize
    end
  end

  scope "/auth", SlackCoder do
    pipe_through :browser

    get "/logout", AuthController, :delete
    delete "/logout", AuthController, :delete
    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
  end

  def graphiql_headers(conn) do
    %{"Authorization" => "Bearer #{SlackCoder.Guardian.Plug.current_token(conn)}"}
  end
end
