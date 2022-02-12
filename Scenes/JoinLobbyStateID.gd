extends LineEdit

var first_time : bool = true


func _on_JoinLobbyStateID_focus_entered():
	if first_time:
		first_time = false
		text = ""
