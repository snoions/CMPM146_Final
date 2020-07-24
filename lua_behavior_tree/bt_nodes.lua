-- require("class")
os.loadAPI("class")

Node = class.class(function(o, name)
	o.name = name
end)

function Node:execute()
    error("not implemented")
end
function Node:tostring()
    return "node name:"..self.name
end


Composite = class.class(Node, function (o, name, child_nodes)
	Node.init(o, name)
	o.child_nodes = child_nodes
end)

function Composite:tree_to_string(indent)
		local str = ""
		for index = 0, indent do 
        	str = str ..'| ' 
        end
        str = str .. self:tostring() ..'\n'
        for _, child in pairs(self.child_nodes) do
            if child.tree_to_string then
                str = str ..child:tree_to_string(indent + 1)
            else
                for index = 0, indent+1 do 
        			str = str ..'| '
        		end
        		str = str ..child:tostring()
        	end
        end
        return str
end


Decorator = class.class(Node, function (o, name, child_node)
	Node.init(o, name)
	o.child_node = child_node
end)


Sequence = class.class(Composite)

function Sequence:execute()
	for k, v in pairs(self.child_nodes)
	do
   		success = v:execute()
   		if not success
   		then 
   			return false
   		end
   	end
   	return true
end

Selector = class.class(Composite)

function Selector:execute()
   for k, v in pairs(self.child_nodes)
   do
   		success = v:execute()
   		if success
   		then 
   			return true
   		end
   end
   return false
end


Leaf = class.class(Node, function (o, name, func)
	Node.init(o, name)
	o.func = func
end)

function Leaf:execute()
    if self.func == nil
    then
    	error("not implemented")
   	else
   		return self.func()
   	end
end




