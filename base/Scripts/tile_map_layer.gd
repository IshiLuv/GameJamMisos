extends TileMapLayer
class_name Tile

func merge_layers(source_layers):
	var offset: Vector2i = Vector2i(2,2)
	for entry in source_layers:

		if entry.size() < 2:
			continue
		var layer: TileMapLayer = entry[0]
		offset += entry[1]

		if layer == null:
			continue

		var used_cells := layer.get_used_cells()
		for cell in used_cells:
			var tile_id = layer.get_cell_source_id(cell)
			var atlas_coords = layer.get_cell_atlas_coords(cell)
			var alternative_tile = layer.get_cell_alternative_tile(cell)

			set_cell(cell + offset, tile_id, atlas_coords, alternative_tile)
			
	for cell_pos in get_used_cells():
		if get_cell_atlas_coords(cell_pos)[1] == 0 and get_cell_atlas_coords(cell_pos) != Vector2i(4,0):
			if get_cell_atlas_coords(cell_pos+Vector2i(0,1)) == Vector2i(4,0):
				set_cell(cell_pos+Vector2i(0,1),0,Vector2i(4,1))
			if get_cell_atlas_coords(cell_pos+Vector2i(0,2)) == Vector2i(4,0):
				set_cell(cell_pos+Vector2i(0,2),0,Vector2i(2,1))
			if get_cell_atlas_coords(cell_pos+Vector2i(0,3)) == Vector2i(4,0):
				set_cell(cell_pos+Vector2i(0,3),0,Vector2i(2,1))
