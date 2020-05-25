defmodule Chromex.BrowserDriver.MessageIdTest do
  use ExUnit.Case

  alias Chromex.BrowserDriver.MessageId

  setup do
    {:ok, _pid} = MessageId.start_link()

    :ok
  end

  describe "MessageId.next/0" do
    test "it returns an id" do
      assert MessageId.next() |> is_integer()
    end

    test "it returns a different id each time" do
      ids = Enum.map(0..10, fn _ -> MessageId.next() end)

      assert ids == Enum.uniq(ids)
    end
  end

  describe "MessageId.subscribe/2" do
    test "it makes a record of id -> pid" do
      id = MessageId.next()
      MessageId.subscribe(id, self())

      assert MessageId.listener(id) == self()
    end

    test "it overwrites and existing listener" do
      id = MessageId.next()
      pid = Process.spawn(fn x -> x end, [])

      MessageId.subscribe(id, pid)
      MessageId.subscribe(id, self())

      assert MessageId.listener(id) == self()
    end
  end

  describe "MessageId.listener/1" do
    test "it returns the listener if there is one" do
      id = MessageId.next()
      MessageId.subscribe(id, self())

      assert MessageId.listener(id) == self()
    end

    test "it returns :none if there is no listener" do
      id = MessageId.next()

      assert MessageId.listener(id) == :none
    end
  end
end
