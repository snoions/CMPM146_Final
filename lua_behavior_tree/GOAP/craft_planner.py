import json
from collections import namedtuple, defaultdict, OrderedDict
from timeit import default_timer as time
from math import inf
from math import ceil
from copy import deepcopy

Recipe = namedtuple('Recipe', ['name', 'check', 'effect', 'cost', 'rule'])


class State(OrderedDict):
    """ This class is a thin wrapper around an OrderedDict, which is simply a dictionary which keeps the order in
        which elements are added (for consistent key-value pair comparisons). Here, we have provided functionality
        for hashing, should you need to use a state as a key in another dictionary, e.g. distance[state] = 5. By
        default, dictionaries are not hashable. Additionally, when the state is converted to a string, it removes
        all items with quantity 0.

        Use of this state representation is optional, should you prefer another.
    """

    def __key(self):
        return tuple(self.items())

    def __hash__(self):
        return hash(self.__key())

    def __lt__(self, other):
        return self.__key() < other.__key()

    def copy(self):
        new_state = State()
        new_state.update(self)
        return new_state

    def __str__(self):
        return str(dict(item for item in self.items() if item[1] > 0))


def make_checker(rule):
    # Implement a function that returns a function to determine whether a state meets a
    # rule's requirements. This code runs once, when the rules are constructed before
    # the search is attempted.
    '''
    print ("produces: " + str(rule['Produces']))
    if 'Requires' in rule:    
        for key in rule['Requires']:
            print(key + ' ' + str(rule['Requires'][key]))
    if 'Consumes' in rule:
        for key in rule['Consumes']:
            print(key + ' ' + str(rule['Consumes'][key]))
    '''

    def check(state):
        # This code is called by graph(state) and runs millions of times.
        # Tip: Do something with rule['Consumes'] and rule['Requires'].
        
        if 'Requires' in rule:
            for key in rule['Requires']:
                if rule['Requires'][key]:
                    if state[key] < 1:
                        return False
        if 'Consumes' in rule:
            for key in rule['Consumes']:
                if state[key] < rule['Consumes'][key]:
                    return False
        return True    
        
        

    return check


def make_effector(rule):
    # Implement a function that returns a function which transitions from state to
    # new_state given the rule. This code runs once, when the rules are constructed
    # before the search is attempted.

    def effect(state):
        # This code is called by graph(state) and runs millions of times
        # Tip: Do something with rule['Produces'] and rule['Consumes'].
        new_state = state.copy()
        if 'Consumes' in rule:
            for key in rule['Consumes']:
                new_state[key] = state[key] - rule['Consumes'][key]
        if 'Produces' in rule:
            for key in rule['Produces']:
                new_state[key] = state[key] + rule['Produces'][key]
        return new_state

    return effect


def make_goal_checker(goal):
    # Implement a function that returns a function which checks if the state has
    # met the goal criteria. This code runs once, before the search is attempted.

    def is_goal(state):
        # This code is used in the search process and may be called millions of times.
        for key in goal:
            if state[key] < goal[key]:
                return False
        return True

    return is_goal


def graph(state):
    # Iterates through all recipes/rules, checking which are valid in the given state.
    # If a rule is valid, it returns the rule's name, the resulting state after application
    # to the given state, and the cost for the rule.
    for r in all_recipes:
        if r.check(state):
            yield (r.name, r.effect(state), r.cost)


def heuristic(state,cameFrom, currentItemTotals):
    # Implement your heuristic here!
    
    for key in state:
        if state[key] > 1 and (key in nonConsumables) and (key not in goalItems):
            return inf
    
    if is_goal(state):
        return 0

    '''
    for key in state:
        if key in goalItems and cameFrom[str(state)] != None:
            if  state[key] > cameFrom[str(state)][0][key]:
                return 0
    '''

    for key in state:
        if key not in itemTotals and state[key] > 0:
            return inf
    

    if cameFrom[str(state)] != None:
        prevState, name = cameFrom[str(state)]
        for r in all_recipes:
            if r.name == name and 'Produces' in r.rule:
                needed = False
                for key in r.rule['Produces']:
                    if key in currentItemTotals:
                        if currentItemTotals[key] > 0:
                            currentItemTotals[key] -= r.rule['Produces'][key]
                            if currentItemTotals[key] < 0:
                                currentItemTotals[key] = 0
                            needed = True
                            
    '''
                if not needed and 'Consumes' in r.rule:
                    for key in r.rule['Consumes']:
                        if key in currentItemTotals:
                            if currentItemTotals[key] > 0:
                                currentItemTotals[key] += r.rule['Consumes'][key]
    '''
    '''
    timeFinishedSoFar = 0
    for key in currentItemTotals:
        if key in goalItems:
            timeFinishedSoFar += currentItemTotals[key] * estimatedTime
        else:
            timeFinishedSoFar += currentItemTotals[key] * ceil(estimatedTime/len(itemTotals)) * 30

    return timeFinishedSoFar
    '''
           
    timeFinishedSoFar = 0
    for key in currentItemTotals:
        if key in goalItems:
            timeFinishedSoFar += currentItemTotals[key] * (estimatedTime)*10000
        else:
            timeFinishedSoFar += currentItemTotals[key] * ceil(estimatedTime/len(itemTotals))*20000

    return timeFinishedSoFar+10
    

import heapq

def search(graph, state, is_goal, limit, heuristic):


    start_time = time()

    # Implement your search here! Use your heuristic here!
    # When you find a path to the goal return a list of tuples [(state, action)]
    # representing the path. Each element (tuple) of the list represents a state
    # in the path and the action that took you to this state
    
    #Algorithm adapted from wikipedia
    #searches for best time process
    q = []
    heapq.heappush(q,(0,"start",state,itemTotals.copy()))
    cameFrom = {}
    gScore = {} #shortest known path to state so far
    fScore = {} #for state fScore[str(state)] = gScore[str(state)] + heuristic(state)
    cameFrom[str(state)] = None
    gScore[str(state)] = 0
    fScore[str(state)] = inf
    
    while time() - start_time < limit:
    #while len(q) > 0:
        popTuple = heapq.heappop(q)
        score, name, currentState, pointerItemTotals = popTuple
        currentItemTotals = deepcopy(pointerItemTotals)
        
        if is_goal(currentState):
            finalScore = gScore[str(currentState)]
            stateActionList = []
            stateActionList.append((currentState, None))
            if cameFrom[str(currentState)] != None:
                prevState, prevAction = cameFrom[str(currentState)]
                while cameFrom[str(prevState)] != None:
                    stateActionList.append((prevState,prevAction))
                    currentState = prevState
                    prevState, prevAction = cameFrom[str(currentState)]
                stateActionList.append((state,prevAction))
                stateActionList.reverse()
            return stateActionList,  time() - start_time, finalScore
        
        
        for name, next_state, cost in graph(currentState):
            tentative_gScore = gScore[str(currentState)] + cost
            if (str(next_state) not in gScore) or tentative_gScore < gScore[str(next_state)]:
                cameFrom[str(next_state)] = (currentState, name)
                gScore[str(next_state)] = tentative_gScore
                fScore[str(next_state)] = gScore[str(next_state)] + heuristic(next_state, cameFrom, currentItemTotals)
                heapq.heappush(q,(fScore[str(next_state)], name, next_state, currentItemTotals))
                '''
                if(fScore[str(next_state)] != inf):
                    qInE = False
                    for e in q:
                        if next_state == e[2]:
                            qInE = True
                            break
                    if not qInE:
                        heapq.heappush(q,(fScore[str(next_state)], name, next_state, currentItemTotals))
                '''
    
    
    # Failed to find a path
    print(time() - start_time, 'seconds.')
    print("Failed to find a path from", state, 'within time limit.')
    return None

def requiredItems(goalItems):
    totals = {}
    change = False
    for key in goalItems:
        if goalItems[key] >= 1:
            for name, rule, in Crafting['Recipes'].items():
                if 'Produces' in rule and 'Consumes' in rule:
                    if key in rule['Produces']:
                        change = True
                        for consumed in rule['Consumes']:
                            if consumed in totals:
                                #totals[consumed] += ceil((rule['Consumes'][consumed] * goalItems[key])/rule['Produces'][key])
                                totals[consumed] += rule['Consumes'][consumed] * ceil(goalItems[key]/rule['Produces'][key])
                            else:
                                #totals[consumed] = ceil((rule['Consumes'][consumed] * goalItems[key])/rule['Produces'][key])
                                totals[consumed] = rule['Consumes'][consumed] * ceil(goalItems[key]/rule['Produces'][key])
                        if 'Requires' in rule:
                            for requires in rule['Requires']:
                                totals[requires] = 1

    if not change:
        return None
    else:
        return totals

if __name__ == '__main__':
    with open('crafting.json') as f:
        Crafting = json.load(f)

    # # List of items that can be in your inventory:
    # print('All items:', Crafting['Items'])
    #
    # # List of items in your initial inventory with amounts:
    # print('Initial inventory:', Crafting['Initial'])
    #
    # # List of items needed to be in your inventory at the end of the plan:
    # print('Goal:',Crafting['Goal'])
    #
    # # Dict of crafting recipes (each is a dict):
    # print('Example recipe:','craft stone_pickaxe at bench ->',Crafting['Recipes']['craft stone_pickaxe at bench'])

    # Build rules
    all_recipes = []
    for name, rule in Crafting['Recipes'].items():
        checker = make_checker(rule)
        effector = make_effector(rule)
        recipe = Recipe(name, checker, effector, rule['Time'], rule)
        all_recipes.append(recipe)

    nonConsumables = {}
    for name, rule in Crafting['Recipes'].items():
        if 'Requires' in rule:
            for key in rule['Requires']:
                if rule['Requires'][key]:
                    nonConsumables[key] = True

    #ITEMS FOR HEURSTIC
    goalItems = Crafting['Goal']
    change = True
    itemTotals = {}
    temp = requiredItems(goalItems)
    while temp != None:
        for key in temp:
            if key not in itemTotals:
                itemTotals[key] = temp[key]
            elif key in nonConsumables:
                temp[key] = 0
            else:
                itemTotals[key] += temp[key]
        temp = requiredItems(temp)
    
    for key in goalItems:
        if key not in itemTotals:
            itemTotals[key] = goalItems[key]
        else:
            itemTotals[key] += goalItems[key]
    '''
    for key in nonConsumables:
        if key in itemTotals:
            continue
        itemTotals[key] = 1
        temp = {key: 1}
        temp = requiredItems(temp)
        while temp != None:
            for key in temp:
                if key not in itemTotals:
                    itemTotals[key] = temp[key]
                elif key in nonConsumables:
                    temp[key] = 0
                else:
                    itemTotals[key] += temp[key]
            temp = requiredItems(temp)
    '''
    '''
    
    if 'ingot' in itemTotals:
        itemTotals['stone_pickaxe'] = 1
        temp = {'stone_pickaxe': 1}
        temp = requiredItems(temp)
        while temp != None:
            for key in temp:
                if key not in itemTotals:
                    itemTotals[key] = temp[key]
                elif key in nonConsumables:
                    temp[key] = 0
                else:
                    itemTotals[key] += temp[key]
            temp = requiredItems(temp)
    if 'cobble' in itemTotals:
        itemTotals['wooden_pickaxe'] = 1
        temp = {'wooden_pickaxe': 1}
        temp = requiredItems(temp)
        while temp != None:
            for key in temp:
                if key not in itemTotals:
                    itemTotals[key] = temp[key]
                elif key in nonConsumables:
                    temp[key] = 0
                else:
                    itemTotals[key] += temp[key]
            temp = requiredItems(temp)

    itemTotals['iron_pickaxe'] = 1
    temp = {'iron_pickaxe': 1}
    temp = requiredItems(temp)
    while temp != None:
        for key in temp:
            if key not in itemTotals:
                itemTotals[key] = temp[key]
            elif key in nonConsumables:
                temp[key] = 0
            else:
                itemTotals[key] += temp[key]
        temp = requiredItems(temp)
    '''

    estimatedTime = 0
    for key in itemTotals:
        estimatedTime += itemTotals[key]


    # Create a function which checks for the goal
    is_goal = make_goal_checker(Crafting['Goal'])

    # Initialize first state from initial inventory
    state = State({key: 0 for key in Crafting['Items']})
    state.update(Crafting['Initial'])
    '''
    for key in Crafting['Items']:
        print(key)
    '''
    '''
    for key in Crafting['Items']:
        print(state[key])
    '''
    print(state['bench'])

    # Search for a solution
    resulting_plan, algorithmTime, planExecuteTime = search(graph, state, is_goal, 30, heuristic)

    if resulting_plan:
        # Print resulting plan
        for state, action in resulting_plan:
            if state != None:
                pass
                #print('\t',state)
            if action != None:
                print(action)
        print('plan length: ', len(resulting_plan)-1)
        print ('took ' + str(algorithmTime) + ' seconds')
        print ('Final Cost: ' + str(planExecuteTime))
