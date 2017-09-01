defmodule SlackCoder.Router do
  use SlackCoder.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Ueberauth
    plug :assign_current_user
  end

  pipeline :restricted do
    plug SlackCoder.VerifyUser
  end

  pipeline :admin do
    plug SlackCoder.VerifyUser, admin: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser # Use the default browser stack

    get "/", SlackCoder.PageController, :index

    scope "/" do
      pipe_through :restricted
      resources "/users", SlackCoder.UserController, only: [:index, :new, :create, :edit, :update]

      scope "/admin" do
        pipe_through :admin

        forward "/graphiql", Absinthe.Plug.GraphiQL, schema: SlackCoder.GraphQL.Schemas.MainSchema

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

    forward "/graphql", Absinthe.Plug, schema: SlackCoder.GraphQL.Schemas.MainSchema

    get "/pull_requests/:owner/:repo/:pr/refresh", PageController, :synchronize

    post "/github/event", GithubController, :event
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

  # Fetch the current user from the session and add it to `conn.assigns`. This
  # will allow you to have access to the current user in your views with
  # `@current_user`.
  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end
end
