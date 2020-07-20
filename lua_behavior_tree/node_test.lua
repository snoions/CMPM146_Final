require('bt_nodes') 


task2 = Leaf( "task1", function() print("first function") return true end)
task1 = Leaf( "task2", function() print("second function") return true end)
sequence = Sequence("S",{task1, task2})
sequence:execute()
print(sequence:tree_to_string(1))
