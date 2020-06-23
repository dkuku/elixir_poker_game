defmodule Player do
  use TypedStruct

  @typedoc "Defines poker player"
  typedstruct do
    field(:hand, list())
  end
end
