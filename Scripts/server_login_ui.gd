extends Control

class_name ServerLoginUi

@onready var email_le:    LineEdit = %EmailLE
@onready var password_le: LineEdit = %PasswordLE
@onready var username_le: LineEdit = %UsernameLE
@onready var login_b:     Button   = %LogInB

@export var out: OverlayOutput
@export var nc: GooseClient

const SAVE_DATA_PATH = "user://savegame.save"

const DEVELOPMENT_MODE = true

func _ready():
	var o: Dictionary = {}
	
	await Incremental.timer.timeout
	
	if DEVELOPMENT_MODE:
		o = {
			email = "email%d@email.com" % Incremental.nth,
			password = "password",
			username = "user%d" % Incremental.nth,
		}
	else:
		o = _load_data()
		
	if o != null:
		if o.has('email'):    email_le.text    = o['email']
		if o.has('password'): password_le.text = o['password']
		if o.has('username'): username_le.text = o['username']
	login_b.pressed.connect(_on_log_in_pressed)

func _save_data():
	var o = {
		email = email_le.text,
		password = password_le.text,
		username = username_le.text,
	}
	
	if !DEVELOPMENT_MODE:
		var save_game = FileAccess.open(SAVE_DATA_PATH, FileAccess.WRITE)
		if save_game == null: return
		save_game.store_line(JSON.stringify(o))
	
	return o
	
func _load_data():
	var save_game = FileAccess.open(SAVE_DATA_PATH, FileAccess.READ)
	if save_game == null: return null
	var json = save_game.get_line()
	var o = JSON.parse_string(json)
	return o

func _on_log_in_pressed():
	var o = _save_data()
	visible = false
	
	nc.email = o.email
	nc.password = o.password
	nc.username = o.username
	nc.connectToServer()
