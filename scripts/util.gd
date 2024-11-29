
class_name Util
extends Node

## The [method decompose_in_powers_of_2] method takes an [code]integer[/code]
## and decomposes it into an [Array] of [code]integers[/code],
## where each [code]integer[/code] is a power of [code]2[/code].
## This representation breaks down the original [code]integer[/code]
## into the sum of powers of [code]2[/code] that add up to the original value.
static func decompose_in_powers_of_2(num: int) -> Array[int]:
	var result: Array[int] = []
	var i: int = 0
	
	while num > 0:
		if num & 1 == 1:
			result.append(1 << i)
		
		num >>= 1
		i += 1
	
	return result

static func untype_array(array: Array) -> Array:
	return array

static func cast_array(array: Array, type: Variant.Type) -> Array:
	var result: Array = []
	
	for element: Variant in array:
		match type:
			TYPE_INT: result.append(int(element))
			_: push_error("Unsupported type: " + str(type))
	
	return result
