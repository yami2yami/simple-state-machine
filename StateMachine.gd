class_name StateMachine

extends Object

var _object
var _state_map
var _current_state = ""

func _init(object: Object, state_map: Dictionary):
	_object = object
	_state_map = state_map

func run(context_or_state, state = null):
	var new_state
	var context

	# If the signal that caused this transition has a payload, it is stored in
	# the first argument. The second argument is the name of the new state.
	# If no payload is passed, the first and only argument is the name of the
	# new state.
	if state == null:
		new_state = context_or_state
		context = null
	else:
		new_state = state
		context = context_or_state

	# Unbind the old transition signal listeners.
	if _current_state:
		for transition in _state_map[_current_state]:
			_object.disconnect(transition, self, "run")

	# Bind listeners to the transition signals for the new state.
	for transition in _state_map[new_state]:
		var next_state = _state_map[new_state][transition]
		_object.connect(transition, self, "run", [next_state])

	# Invoke the state function. If the signal did not provide a context or the
	# context was empty (i.e. null) do not pass it as an argument.
	var state_func = funcref(_object, new_state)
	state_func.call_funcv([context] if context else [])
	_current_state = new_state
