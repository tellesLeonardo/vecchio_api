defmodule VecchioApiWeb.Router do
  use VecchioApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug VecchioApiWeb.Plugs.CORS
    plug VecchioApiWeb.Plugs.RequestLogger
  end

  scope "/", VecchioApiWeb do
    pipe_through :api

    post "/", Command, :command
  end
end
