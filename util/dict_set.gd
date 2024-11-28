
class_name DictSet
extends RefCounted

var elements: Dictionary = {}

func set_element(element: Variant) -> void:
	elements[element] = true

func has_element(element: Variant) -> bool:
	return elements.has(element)

func remove_element(element: Variant) -> bool:
	return elements.erase(element)

func get_as_array() -> Array:
	return elements.keys()

func copy() -> DictSet:
	var result := DictSet.new()
	
	for element: Variant in get_as_array():
		result.set_element(element)
	
	return result

func union(other_set: DictSet) -> DictSet:
	var result: DictSet = self.copy()
	
	for element: Variant in other_set.get_as_array():
		result.set_element(element)
	
	return result

func difference(other_set: DictSet) -> DictSet:
	var result := DictSet.new()
	
	for element: Variant in get_as_array():
		if other_set.has_element(element):
			continue
		
		result.set_element(element)
	
	return result
