defmodule Bombadil.Ecto.Schema.DynamicSchema do
  @jsonb_field [{:data, :map}]
  @fields Application.get_env(:bombadil, :additional_fields, [])
  @table_name Application.get_env(:bombadil, :table_name, "search_index")

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @derive {Jason.Encoder, only: Keyword.keys(unquote(@fields ++ @jsonb_field))}

      schema unquote(@table_name) do
        unquote(
          for {name, type} <- @fields ++ @jsonb_field do
            quote do
              field(unquote(name), unquote(type))
            end
          end
        )
      end
    end
  end
end
