extends Node2D


@onready var UI : Control = $DialogueUI
@onready var Title : Control = UI.get_node("Title")
@onready var TitleText : RichTextLabel = Title.get_node("TitleCardText")
@onready var DialogueText : RichTextLabel = UI.get_node("DialogueText")
@onready var Sounds : Node2D = $Sounds


# machinary
var timers := {}
enum States {
	WAITING,
	SAYING
}
var state : States

var text_block := ""
var index := 0
var current_text := ""
var current_title := ""

func _ready():
	GlobalBus.set_dialogue_reference(self)
	state = States.WAITING
	UI.visible = false

	UI.get_node("DialogueBox").size = Vector2(320, 80)
	DialogueText.size = Vector2(286, 44)


func _physics_process(_delta):
	process_state()
	process_controls()

	for timer in timers:
		timers[timer] -= 1

func process_state():
	if state == States.SAYING:
		if check_timer("typing", true) and len(current_text) > DialogueText.visible_characters:
			DialogueText.visible_characters += 1
			index += 1
			if current_text[DialogueText.visible_characters-1] in [',',';',':','—']:
				set_timer("typing", 15)
			elif current_text[DialogueText.visible_characters-1] in ['.','?','!']:
				set_timer("typing", 25)
			else:
				set_timer("typing", 3)
			if randi() % 2 == 0:
				Sounds.get_node("TalkSound").play()


func set_state(new_state):
	var prev_state = state
	state = new_state

	if state == States.SAYING:
		GlobalBus.dialoguing = true
		UI.visible = true
		load_next_chunk()
		if current_title != "":
			Title.visible = true
			TitleText.text = current_title



	if state == States.WAITING:
		GlobalBus.dialoguing = false
		UI.visible = false
		current_title = ""
		text_block = ""
		current_text = ""
		DialogueText.text = ""
		index = 0


func process_controls():
	if state == States.WAITING:
		return


	if Input.is_action_just_pressed("a"):
		# if fully done
		if index >= len(text_block):			
			set_state(States.WAITING)
			return

		# if currently typing
		if DialogueText.visible_characters < len(current_text):
			index += len(current_text) - DialogueText.visible_characters
			DialogueText.visible_characters = len(current_text)
		else:
			# start new chunk
			load_next_chunk()
			DialogueText.visible_characters = 0
			Title.visible = false
			Sounds.get_node("NextSound").play()

func attempt_dialogue(obj : Node2D):
	if "dialogue" in obj:
		if "title" in obj:	
			say(obj.dialogue, obj.title)
		else:
			say(obj.dialogue)
		return true
	else:
		return false


func say(text : String, title : String = ""):
	text_block = text
	current_title = title
	set_state(States.SAYING)


func load_next_chunk():
	current_text = ""
	var remaining_words = text_block.substr(index).split(" ")
	var word_count = 0
	var line_count = 0
	var line_marker = 0
	for word in remaining_words:
		# break out conditions
		if get_dialogue_length(current_text.substr(line_marker) + word).x > .95*DialogueText.size.x:
			if word_count > 3:
				line_count += 1
				word_count = 0
				line_marker = len(current_text)
			else:
				# add a portion of the new word
				var word_length = get_dialogue_length(word).x
				var proportion = (.95*DialogueText.size.x - get_dialogue_length(current_text.substr(line_marker) + word).x / word_length)
				current_text = current_text + word.substr(floor(proportion*len(word)))
				line_count += 1
				word_count = 0
				line_marker = len(current_text)
		if line_count > 2:
			break
		# loop body
		current_text = current_text + word + " "
		word_count += 1
	DialogueText.text = current_text
	DialogueText.visible_characters = 0


	# try by word




# ================================== TIMER =============================================

func set_timer(_name, value):
	timers[_name] = value

func check_timer(_name, read_null_as = false) -> bool:
	if timers.get(_name) == null:
		return read_null_as
	if timers.get(_name) < 1:
		return true
	return false

func rm_timer(_name):
	timers.erase(_name)









# convenience

func get_dialogue_length(text):
	return DialogueText.get_theme_font("normal_font").get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
