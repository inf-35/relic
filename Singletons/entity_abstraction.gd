extends Node


var skin_pools : Dictionary = {} #format {"skin" : [SKIN,SKIN,SKIN,SKIN]}
#stores unused pull skins

#to prevent cyclic reference
func spawn_request(skin : String) -> Node:
	var result : Node
	
	if not EntityDirector.entity_skin_scenes.has(skin):
		return
		
	#if skin_pools.has(skin):
		#var skin_pool : Array = skin_pools[skin]
		#if len(skin_pool) > 0:
			#print("success")
			#result = skin_pool[0]
			#skin_pool.remove_at(0)
	#else:
		#skin_pools[skin] = [] #create new pool
		
	if not result:
		result = EntityDirector.entity_skin_scenes[skin].instantiate()
	
	
		
	return result
