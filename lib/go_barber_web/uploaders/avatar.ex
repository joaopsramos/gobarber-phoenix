defmodule GoBarberWeb.Uploaders.Avatar do
  use Waffle.Definition

  @versions [:original]

  def storage_dir(_, {_file, _scope}) do
    "tmp/user/avatar"
  end
end
