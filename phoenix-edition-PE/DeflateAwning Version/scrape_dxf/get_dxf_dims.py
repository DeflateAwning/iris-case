import ezdxf
import json
from statistics import mean

def print_object_dimensions(entity, doc, elements: list, parent_uuid):
	element = {
		'type': entity.dxftype(),
		'uuid': str(entity.uuid),
		'parent_uuid': str(parent_uuid),
	}

	if entity.dxftype() == 'LINE':
		length = entity.dxf.end - entity.dxf.start
		print(f"Line: length = {length:.2f}")
		element.update({'length': length, 'end': entity.dxf.end, 'start': entity.dxf.start})

	elif entity.dxftype() == 'CIRCLE':
		radius = entity.dxf.radius
		element.update({'raduis': radius})
		print(f"Circle: radius = {radius:.2f}")

	elif entity.dxftype() == 'ARC':
		radius = entity.dxf.radius
		angle = entity.dxf.end_angle - entity.dxf.start_angle
		element.update({'raduis': radius, 'end_angle': entity.dxf.end_angle, 'start_angle': entity.dxf.start_angle})
		print(f"Arc: radius = {radius:.2f}, angle = {angle:.2f}")

	elif entity.dxftype() == 'ELLIPSE':
		major_axis = entity.dxf.major_axis
		minor_axis = entity.dxf.minor_axis
		element.update({'major_axis': major_axis, 'minor_axis': minor_axis})
		print(f"Ellipse: major axis = {major_axis:.2f}, minor axis = {minor_axis:.2f}")

	elif entity.dxftype() == 'SPLINE':
		degree = entity.dxf.degree
		control_points_count = len(entity.control_points)
		knots_count = len(entity.knots)
		control_points = [tuple(i) for i in entity.control_points]

		element.update({
			'degree': degree,
			'control_points_count': control_points_count,
			'knots_count': knots_count,
			'control_points': [tuple(i) for i in entity.control_points],
			'knots': list(entity.knots),

			'cp_x_min': min([i[0] for i in control_points]),
			'cp_x_max': max([i[0] for i in control_points]),
			'cp_y_min': min([i[1] for i in control_points]),
			'cp_y_max': max([i[1] for i in control_points]),

			'cp_x_avg': mean([i[1] for i in control_points]),
			'cp_y_avg': mean([i[1] for i in control_points]),
		})
		print(f"Spline: degree = {degree}, control points = {control_points_count}, knots = {knots_count}")

	elif entity.dxftype() == 'SCALE':
		scale = entity.dxf.text
		element.update({'scale': scale})
		print(f"Insert: scale = {scale}")

	elif entity.dxftype() == 'INSERT':
		block = doc.blocks[entity.dxf.name]
		print(f"Insert: blocks = {len(block)}")
		element.update({'child_count': len(block)})

		for entity in block:
			print_object_dimensions(entity, doc, elements, parent_uuid=element['uuid']) # recursive

	else:
		print(f"Unknown entity type: {entity.dxftype()}")

	elements.append(element)

def print_dimensions(filename):
	doc = ezdxf.readfile(filename)
	modelspace = doc.modelspace()
	print(f"Found {len(modelspace)} entities in the modelspace.")
	
	# if len(modelspace) == 1 and modelspace[0].dxftype() == 'INSERT':
	# 	print(f"Using the 'INSERT' entity technique.")

	# 	entity = modelspace[0]
	# 	block = doc.blocks[entity.dxf.name]
	# 	for entity in block:
	# 		print_object_dimensions(entity)

	elements = []
	
	for entity in modelspace:
		print_object_dimensions(entity, doc, elements, parent_uuid='top')

	with open('dump.json', 'w') as fp:
		json.dump(elements, fp, indent=4)

	print(f"Dumped {len(elements)} elements to JSON file.")

if __name__ == '__main__':
	filename = 'iris-PE-bottom-plate.dxf'
	print_dimensions(filename)

