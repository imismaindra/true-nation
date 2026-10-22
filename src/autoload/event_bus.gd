# event_bus.gd
# Global Event Bus untuk komunikasi antar-sistem tanpa tight coupling.
extends Node

# Sinyal Interaksi Peta & Wilayah
@warning_ignore("unused_signal")
signal province_clicked(province_node)
@warning_ignore("unused_signal")
signal province_hovered(province_node)
@warning_ignore("unused_signal")
signal province_owner_changed(province_node, old_owner, new_owner)

# Sinyal Militer & Tempur
@warning_ignore("unused_signal")
signal unit_selected(unit_node)
@warning_ignore("unused_signal")
signal unit_deselected()
@warning_ignore("unused_signal")
signal unit_movement_started(unit_node, from_province, to_province)
@warning_ignore("unused_signal")
signal unit_movement_finished(unit_node, province)
@warning_ignore("unused_signal")
signal combat_started(province_node, attacker_units: Array, defender_units: Array)
@warning_ignore("unused_signal")
signal combat_ended(province_node, winner_country)
@warning_ignore("unused_signal")
signal battle_report(report: Dictionary)

# Sinyal Ekonomi
@warning_ignore("unused_signal")
signal resource_updated(country, resource_type: String, new_amount: float)
