defmodule MoveWeb.InstanceView do
  use MoveWeb, :view
  @config %{
    "en" => [precision: 2, delimiter: ",", separator: "."],
    "fr" => [precision: 2, delimiter: " ", separator: ","]
  }

  def size(bytes, locale) do
    bytes / 1_000_000
    |> Number.Delimit.number_to_delimited(@config[locale])
  end
end
