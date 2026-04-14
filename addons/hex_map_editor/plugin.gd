@tool
extends EditorPlugin

var main_panel_instance: Control

func _enter_tree() -> void:
	var MainPanelScript = preload("res://addons/hex_map_editor/ui/main_panel.gd")
	main_panel_instance = MainPanelScript.new()
	# Optional: Give it a nice name
	main_panel_instance.name = "HexMapEditor"
	
	# Add to the main editor viewport or bottom panel. Bottom panel is usually easier to debug.
	add_control_to_bottom_panel(main_panel_instance, "Hex Editor")

func _exit_tree() -> void:
	if main_panel_instance:
		remove_control_from_bottom_panel(main_panel_instance)
		main_panel_instance.queue_free()
