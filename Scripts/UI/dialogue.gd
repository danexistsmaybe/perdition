extends Node2D


@onready var UI : Control = $DialogueUI
@onready var Title : Control = UI.get_node("Title")
@onready var TitleText : RichTextLabel = Title.get_node("TitleCardText")
@onready var DialogueText : RichTextLabel = UI.get_node("DialogueText")


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
	var chr_count = 0
	var word_count = 0
	for word in remaining_words:
		# break out conditions
		if len(word) + chr_count > 90:
			if word_count > 5:
				break
			else:
				# add a portion of the new word
				current_text = current_text + word.substr(clamp(60 - len(current_text), 2, 30))
				break
		
		# loop body
		current_text = current_text + word + " "
		word_count += 1
		chr_count += (1 + len(word))
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
