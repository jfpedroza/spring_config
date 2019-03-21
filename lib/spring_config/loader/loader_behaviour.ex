defmodule SpringConfig.Loader.LoaderBehaviour do
  @moduledoc """
    Defines a behaviour for loading configuration from different sources
  """

  @doc """
  Loads the configuration from a single source. The options accepted depend on each implementation of this behaviour.
  """
  @callback load(opts :: Keyword.t()) :: no_return()
end
