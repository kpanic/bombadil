defmodule BombadilTest do
  use Bombadil.RepoCase
  doctest Bombadil

  describe "indexing" do
    test "simple data" do
      assert :ok = Bombadil.index(data: %{"ask" => "ciao"})
    end

    test "index data with additional fields" do
      assert :ok =
               Bombadil.index(
                 data: %{"ask" => "ciao"},
                 test: "I was generated by config dynamically!"
               )

      assert [%_{data: %{"ask" => "ciao"}, test: "I was generated by config dynamically!"}] =
               Bombadil.search([%{"ask" => "ciao"}])
    end
  end

  describe "search with list of maps" do
    test "search data (exact match with multiple criterias)" do
      assert :ok = Bombadil.index(data: %{"ask" => "ciao"})
      assert :ok = Bombadil.index(data: %{"ask" => "ciao2"})

      assert [%_{data: %{"ask" => "ciao"}}, %_{data: %{"ask" => "ciao2"}}] =
               Bombadil.search([%{"ask" => "ciao"}, %{"ask" => "ciao2"}])
    end

    test "search data (exact match with one criteria)" do
      assert :ok = Bombadil.index(data: %{"ask" => "ciao"})
      assert [%_{data: %{"ask" => "ciao"}}] = Bombadil.search([%{"ask" => "ciao"}])
    end

    test "search data (does not match)" do
      assert :ok = Bombadil.index(data: %{"ask" => "hello"})
      assert [] = Bombadil.search([%{"ask" => "ciao"}])
    end
  end

  describe "full text search" do
    test "simple match" do
      assert :ok = Bombadil.index(data: %{"ask" => "ciao"})
      assert :ok = Bombadil.index(data: %{"ask" => "ciao2"})
      assert [%_{data: %{"ask" => "ciao2"}}] = Bombadil.search("ciao2")
    end

    test "simple match with metadata" do
      assert :ok =
               Bombadil.index(
                 data: %{"ask" => "hello world", "metadata" => [%{"meta" => "data"}]}
               )

      assert [%_{data: %{"ask" => "hello world", "metadata" => [%{"meta" => "data"}]}}] =
               Bombadil.search("hello world")
    end
  end

  describe "fuzzy search" do
    test "simple match" do
      assert :ok =
               Bombadil.index(
                 data: %{"ask" => "hello fuzzy", "metadata" => [%{"meta" => "data"}]}
               )

      assert [%_{data: %{"ask" => "hello fuzzy", "metadata" => [%{"meta" => "data"}]}}] =
               Bombadil.fuzzy_search("hello fuzzy")
    end

    test "simple fuzy match on a specific field" do
      assert :ok = Bombadil.index(data: %{"ask" => "hello fuzzy"})
      assert :ok = Bombadil.index(data: %{"dont_look_at_me" => "hello fuzzy"})

      assert [%_{data: %{"ask" => "hello fuzzy"}, id: _id, test: _test}] =
               Bombadil.fuzzy_search([%{"ask" => "hello fuzy"}])
    end

    test "simple speling error match" do
      assert :ok =
               Bombadil.index(
                 data: %{"ask" => "hello fuzzy", "metadata" => [%{"meta" => "data"}]}
               )

      assert [%{data: %{"ask" => "hello fuzzy", "metadata" => [%{"meta" => "data"}]}}] =
               Bombadil.fuzzy_search("fuzy")
    end

    test "speling error match with nested data" do
      assert :ok =
               Bombadil.index(
                 data: %{
                   "data" => %{"ask" => "hello fuzzy"},
                   "metadata" => [%{"meta" => "data"}]
                 }
               )

      assert [
               %_{
                 data: %{
                   "data" => %{
                     "ask" => "hello fuzzy"
                   },
                   "metadata" => [%{"meta" => "data"}]
                 }
               }
             ] = Bombadil.fuzzy_search("fuzy")
    end
  end

  describe "search with a context" do
    test "and fuzzy search" do
      assert :ok = Bombadil.index(item_id: 42, data: %{"ask" => "hello fuzzy"})

      assert :ok =
               Bombadil.index(
                 item_id: 42,
                 data: %{"ask" => "I am hiding with the same id, don't find me!"}
               )

      assert :ok = Bombadil.index(item_id: 24, data: %{"dont_look_at_me" => "hello fuzzy"})
      assert :ok = Bombadil.index(data: %{"dont_look_at_me" => "hello fuzzy"})

      assert [%_{data: %{"ask" => "hello fuzzy"}, id: _id, test: _test, item_id: 42}] =
               Bombadil.fuzzy_search([%{"ask" => "hello fuzy"}], context: %{item_id: 42})

      assert [%_{data: %{"ask" => "hello fuzzy"}, id: _id, test: _test, item_id: 42}] =
               Bombadil.fuzzy_search("hello fuzy", context: %{item_id: 42})
    end
  end
end
