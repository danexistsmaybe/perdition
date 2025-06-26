extends Node2D


func _ready():
	$TextureRect.texture = $SubViewport.get_texture()
	$TextureRect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	$SubViewport.snap_2d_transforms_to_pixel = true
