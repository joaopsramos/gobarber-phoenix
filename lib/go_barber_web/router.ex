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

    live "/", PageLive, :index

    live "/signin", SessionLive.New

    post "/session", SessionController, :create
    delete "/session", SessionController, :delete

    get "/signup", UserController, :new

    get "/provider", ProviderController, :index
    get "/customer", CustomerController, :index
  end

  scope "/provider", GoBarberWeb.Provider, as: :provider do
    pipe_through [:browser, :authenticate_user, :requires_provider]

    get "/dashboard", DashboardController, :index
  end

  scope "/customer", GoBarberWeb.Customer, as: :customer do
    pipe_through [:browser, :authenticate_user, :requires_customer]

    get "/dashboard", DashboardController, :index
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
