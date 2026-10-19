# event_bus.gd
# Global Event Bus untuk komunikasi antar-sistem tanpa tight coupling.
extends Node

# Sinyal Interaksi Peta & Wilayah
signal province_clicked(province_node)
signal province_hovered(province_node)
signal province_owner_changed(province_node, old_owner, new_owner)

# Sinyal Militer & Tempur
signal unit_selected(unit_node)
signal unit_deselected()
signal unit_movement_started(unit_node, from_province, to_province)
signal unit_movement_finished(unit_node, province)
signal combat_started(province_node, attacker_units: Array, defender_units: Array)
signal combat_ended(province_node, winner_country)

# Sinyal Ekonomi
signal resource_updated(country, resource_type: String, new_amount: float)
