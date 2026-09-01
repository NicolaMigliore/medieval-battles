extends Node


@onready var innkeeper_trigger :Area3D = $InnkeeperTrigger

func _ready() -> void:
	_setup_triggers()


#region Triggers

func _setup_triggers() -> void:
	innkeeper_trigger.body_entered.connect(func(_body:Node3D): print("Entered"))
	innkeeper_trigger.body_exited.connect(func(_body:Node3D): print("Exited"))

#endregion
	

func innkeeper_dialog() -> void:
	print("Welcome back. Are you here to pay your tab?")