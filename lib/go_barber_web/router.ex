defmodule GoBarberWeb.Router do
  use GoBarberWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GoBarberWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GoBarberWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GoBarberWeb do
    pipe_through :browser

    get "/", Redirect, to: "/signin"

    live "/signin", SessionLive.New

    post "/session", SessionController, :create
    delete "/session", SessionController, :delete

    get "/signup", UserController, :new
    post "/signup", UserController, :create

    get "/provider", ProviderController, :index
    get "/customer", CustomerController, :index

    live "/profile", ProfileLive, :index
  end

  scope "/provider", GoBarberWeb do
    pipe_through [:browser, :authenticate_user, :requires_provider]

    live "/dashboard", ProviderLive.Dashboard, :index
  end

  scope "/customer", GoBarberWeb do
    pipe_through [:browser, :authenticate_user, :requires_customer]

    live "/dashboard", CustomerLive.Dashboard, :index
    live "/appointments/new", CustomerLive.Appointments.New, :new
  end

  # Other scopes may use custom stacks.
  scope "/api", GoBarberWeb.API, as: :api do
    pipe_through :api

    post "/users", UserController, :create
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/live_dashboard", metrics: GoBarberWeb.Telemetry
    end
  end
end
