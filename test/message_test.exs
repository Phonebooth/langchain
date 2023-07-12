defmodule Langchain.MessageTest do
  use ExUnit.Case
  doctest Langchain.Message
  alias Langchain.Message

  describe "new/1" do
    test "works with minimal attrs" do
      assert {:ok, %Message{} = msg} = Message.new(%{"role" => "system", "content" => "hello!"})
      assert msg.role == :system
      assert msg.content == "hello!"
    end

    test "accepts atom keys and role enum" do
      assert {:ok, %Message{} = msg} = Message.new(%{role: :system, content: "hello!"})
      assert msg.role == :system
      assert msg.content == "hello!"
    end

    test "returns error when invalid" do
      assert {:error, changeset} = Message.new(%{"role" => nil})
      refute changeset.valid?
      assert {"can't be blank", _} = changeset.errors[:role]
    end
  end

  describe "validations" do
    test "allows blank content for assistant message" do
      assert {:ok, %Message{} = msg} = Message.new(%{role: :assistant, content: nil})
      assert msg.role == :assistant
      assert msg.content == nil
    end

    test "require content for system and user messages" do
      assert {:error, changeset} = Message.new(%{role: :system, content: nil})
      assert {"can't be blank", _} = changeset.errors[:content]

      assert {:error, changeset} = Message.new(%{role: :user, content: nil})
      assert {"can't be blank", _} = changeset.errors[:content]
    end
  end

  describe "new_system/1" do
    test "creates a system message" do
      assert {:ok, %Message{role: :system} = msg} = Message.new_system("You are an AI.")
      assert msg.content == "You are an AI."
    end

    test "provides default content" do
      assert {:ok, msg} = Message.new_system()
      assert msg.content == "You are a helpful assistant."
    end

    test "requires content" do
      assert_raise Langchain.LangchainError, "content: can't be blank", fn ->
        Message.new_system!(nil)
      end
    end

  end

  describe "new_user/1" do
    test "creates a user message" do
      assert {:ok, %Message{role: :user} = msg} = Message.new_user("Hello!")
      assert msg.content == "Hello!"
    end

    test "requires content" do
      assert {:error, changeset} = Message.new_user(nil)
      assert {"can't be blank", _} = changeset.errors[:content]
    end
  end

  describe "new_user!/1" do
    test "creates a user message" do
      assert %Message{role: :user} = msg = Message.new_user!("Hello!")
      assert msg.content == "Hello!"
    end

    test "requires content" do
      assert_raise Langchain.LangchainError, "content: can't be blank", fn ->
        Message.new_user!(nil)
      end
    end
  end

  describe "new_assistant/1" do
    test "creates a assistant message" do
      assert {:ok, %Message{role: :assistant} = msg} = Message.new_assistant("Greetings non-AI!")
      assert msg.content == "Greetings non-AI!"
    end

    test "does not require content" do
      assert {:ok, %Message{role: :assistant, content: nil}} = Message.new_assistant(nil)
    end
  end

  describe "new_assistant!/1" do
    test "creates a assistant message" do
      assert %Message{role: :assistant} = msg = Message.new_assistant!("Hello!")
      assert msg.content == "Hello!"
    end
  end
end
