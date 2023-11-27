Colors = {
    WHITE = 0,
    GREY = 1,
    BLACK = 2
}
function initGraph(nodes, edges, file)
  local graphList = {}
  for i=1,nodes do
    graphList[i] = {}
  end
  
  for j=1,edges do
    local from, to = file:read("*n","*n")
    table.insert(graphList[from], to)
    table.insert(graphList[to], from)
  end
  
  return graphList
end
function initVisitedCol(nodes)
  local isVisitedCol = {}
  for i = 1,nodes do
    isVisitedCol[i] = Colors.WHITE
  end
  return isVisitedCol
end
function initCycled(nodes)
  local isCycled = {}
  for i = 1, nodes do
    isCycled[i] = false
  end
  return isCycled
end

file = io.open("input.txt", "r")

nodes, edges = file:read("*n","*n")

depthPath = {}
graphList = initGraph(nodes, edges, file)
isVisitedCol = initVisitedCol(nodes)
isCycled = initCycled(nodes)
isCycle = false

file:close()

lowestVertexInCycle = 99999

function dfs(node, from)
  isVisitedCol[node] = Colors.GREY
  table.insert(depthPath, 1, node)

  if #depthPath == 5 then
    local a = 1
  end
  
  for i=1, #graphList[node] do
    local to = graphList[node][i]
    
    if to == from then
      goto continue
    end
    
    if  isVisitedCol[to] == Colors.WHITE then
      dfs(to, node)
    elseif  isVisitedCol[to] == Colors.GREY then
      isCycled[to] = true
      
      for i, nod in ipairs(depthPath) do
        if nod == to or isCycled[nod] then
          break
        end
        isCycled[nod] = true
      end
    end
    
    
  table.remove(depthPath, 1)
  isVisitedCol[node] = Colors.BLACK
  ::continue::
  end
end


for i = 1, #graphList do
    dfs(i, 1)
end

for i = 1, #isCycled do
  if isCycled[i] then
    lowestVertexInCycle = i
    isCycle = true
    break
  end
end


if isCycle then
  print("Yes")
  print(lowestVertexInCycle)
  return
end

print("No")

