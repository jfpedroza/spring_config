defmodule SpringConfig.Loader.LoaderBehaviour do
  @moduledoc """
    Defines a behaviour for loading configuration from different sources
  """

  @callback load(Keyword.t()) :: any
end
