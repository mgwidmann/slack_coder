defmodule SlackCoder.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use SlackCoder.Web, :controller
      use SlackCoder.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      alias SlackCoder.Models.Types.StringList
      alias SlackCoder.Models.Types.Boolean
      require Logger
      import StubAlias
    end
  end

  def controller do
    quote do
      use Phoenix.Controller
      import Ecto
      alias SlackCoder.Repo
      import Ecto.Schema
      import Ecto.Query, only: [from: 1, from: 2]

      alias SlackCoder.Models.{User, Message}

      import SlackCoder.Router.Helpers
      require Logger
      import StubAlias
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SlackCoder.ApplicationHelper
      alias SlackCoder.Models.{User, PR}

      import SlackCoder.Router.Helpers
      import StubAlias
    end
  end

  def router do
    quote do
      use Phoenix.Router
      require Logger
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Ecto
      alias SlackCoder.Repo
      import Ecto.Schema
      import Ecto.Query, only: [from: 1, from: 2]
      require Logger
      import StubAlias
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
