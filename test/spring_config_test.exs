defmodule SpringConfigTest do
  use ExUnit.Case
  doctest SpringConfig

  test "greets the world" do
    assert SpringConfig.hello() == :world
  end
end
