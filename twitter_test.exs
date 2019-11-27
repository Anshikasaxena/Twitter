defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

  describe "Register" do
    test "Register a new user with people(3) in the database" do
      # User1 registring with username - "TA"
      name = "TA"
      pass = "p"
      {password_list, total_users} = Register.reg(name, pass)
      assert total_users == ["isabel", "anshika", "dobra", "TA"]
    end

    test "The registered users (4 in number) have corresponding Client processes (CSA)" do
      # Checking the number of users the Dynamic Supervisor has 
      all_values = DynamicSupervisor.which_children(DySupervisor)
      IO.inspect(all_values, label: "The CSAs")
      assert length(all_values) == 4
    end

    test "Can't Register with an already registered username" do
      Register.reg("isabel", "p")
    end

    test "The registered users have corresponding Engine processes  " do
      names = Register.children()
      #   IO.inspect(names)
      assert length(names) == 4
    end
  end

  describe "Subscribe" do
    test "The subscriber's name is in the follower's and vice versa" do
      # Subscribing 
      # isabel subscribing anshika
      name1 = "isabel"
      name2 = "anshika"
      pid_from = :"#{name1}"
      pid_to = :"#{name2}"
      # GenServer.call(pid_from, {:subscribe, name2})
      {anshika_followers, isabel_subscribed} = Subscribe.subscribe(pid_from, name2)

      assert anshika_followers == [:"#{pid_from}_cssa"]
      assert isabel_subscribed == [:"#{pid_to}_cssa"]
    end
  end

  describe "Delete" do
    test "The engine has removed the process from its list" do
      sender = "dobra"
      id = :"#{sender}"
      Delete.remAsfollower(id)
      {key_pass, subscribed} = Delete.remFromEngine(id)
      Delete.deleteFromCSA(id)
      assert subscribed = ["isabel", "anshika", "TA"]
      assert length(key_pass) == 3
      assert length(subscribed) == 3
    end

    test "The Client process for the deleted user has been deleted" do
      all_values = DynamicSupervisor.which_children(DySupervisor)
      assert length(all_values) == 3
    end
  end
end
