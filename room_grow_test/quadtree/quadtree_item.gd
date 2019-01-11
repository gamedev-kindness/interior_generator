extends Resource
class_name QuadtreeData


class _QuadtreeItem:
	var children = []
	var rect: Rect2
	var polygons = []

	func split_tree():
		for k in range(4):
			children.push_back(_QuadtreeItem.new())
		var r1 = Rect2(rect.position, rect.size / 2)
		var r2 = Rect2(rect.position + Vector2(rect.size.x / 2, 0), rect.size / 2)
		var r3 = Rect2(rect.position + Vector2(0, rect.size.y / 2), rect.size / 2)
		var r4 = Rect2(rect.position + Vector2(rect.size.x, rect.size.y / 2), rect.size / 2)
		var rects = [r1, r2, r3 ,r4]
		for r in range(rects.size()):
			children[r].init(rects[r])
			for p in polygons:
				children[r].add_polygon(p)
		polygons.clear()
		print("split")
	func init(r):
		rect = r
	func find_intersections(polygon: Dictionary):
		var ret = []
		if polygons.size() > 0:
			var r
			if polygon.has("rect"):
				r = polygon.rect
			else:
				r = Rect2()
				for p in polygon.polygon:
					r = r.expand(p)
			if rect.intersects(r) || r.intersects(rect) || rect.encloses(r) || r.encloses(rect):
				for mp in polygons:
					ret.push_back(mp)
		else:
			for c in children:
				ret += c.find_intersections(polygon)
		return ret

	func add_polygon(polygon: Dictionary):
		var r = Rect2()
		for p in polygon.polygon:
			r = r.expand(p)
		polygon.rect = r
		if rect.intersects(r) || r.intersects(rect) || rect.encloses(r) || r.encloses(rect):
			if children.empty():
				print("no children")
				polygons.push_back(polygon)
				if polygons.size() > 4:
					split_tree()
			else:
				print("children: ", children.size())
				var ok = false
				for m in children:
					if m.add_polygon(polygon):
						ok = true
				return ok
		return false
var root: _QuadtreeItem
func init(r: Rect2):
	root = _QuadtreeItem.new()
	root.init(r)

func add_polygon(polygon: Dictionary):
	root.add_polygon(polygon)
func find_intersections(polygon: Dictionary):
	return root.find_intersections(polygon)