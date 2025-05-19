defmodule Bombadil.Ecto.DynamicMigration do
  @moduledoc false

  @jsonb_field [{:payload, :jsonb}]
  @fields Application.get_env(:bombadil, :additional_fields, [])
  @table_name Application.get_env(:bombadil, :table_name, "search_index")

  defmacro run() do
    quote do
      create table(unquote(@table_name)) do
        unquote(
          for {name, type} <- @fields ++ @jsonb_field do
            quote do
              add(unquote(name), unquote(type))
            end
          end
        )
      end
    end
  end
end
