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

    for path <- ["/", "/mobile/login"] do
      get path, SlackCoder.PageController, :index
    end

    scope "/" do
      pipe_through :restricted
      resources "/users", SlackCoder.UserController, only: [:index, :new, :create, :edit, :update]

      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: SlackCoder.GraphQL.Schemas.MainSchema,
        default_headers: {__MODULE__, :graphiql_headers},
        default_url: "/api/graphql"

      scope "/admin" do
        pipe_through :admin

        scope "/", SlackCoder do
          get "/users/external/:github", UserController, :external
          post "/users/external/:github", UserController, :create_external

          get "/messages", UserController, :messages
        end
      end
    end
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

  forward "/errors", Flames.Web
  forward "/wobserver", Wobserver.Web.Router

  scope "/auth", SlackCoder do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", SlackCoder do
  #   pipe_through :api
  # end

  def graphiql_headers(conn) do
    %{"Authorization" => "Bearer #{SlackCoder.Guardian.Plug.current_token(conn)}"}
  end
end
