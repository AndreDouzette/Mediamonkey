dim UI : Set UI = SDB.UI
dim mnu
dim tb
dim playlocked
dim didfinish

'Next and previous buttons still work, not much of a problem?
'Alt+Enter works, thats ok?

sub OnStartup
	'Create a new toolbar section, in the main toolbar
	set tb = UI.AddToolbar("Extra Tools")
	'Adding the button to the toolbar
	Set mnu = UI.addMenuItem(tb, 1, 2)
	'Description
	mnu.Caption = "PlayLock"
	mnu.Hint = "Enables play locking"
	'Button icon
	mnu.IconIndex = 48
	'Button click event
	Script.RegisterEvent mnu, "OnClick", "buttonClick"
	
	playlocked = false
	
	Script.RegisterEvent SDB, "OnPause", "paused"
	Script.RegisterEvent SDB, "OnPlay", "played"
	Script.RegisterEvent SDB, "OnTrackEnd", "finished"
end sub

sub toggleDoubleClick(isoff)
	'Disables selecting new track
	if isoff then
		Script.RegisterEvent SDB, "OnTrackDoubleClick", "doubleClick"
	else
		Script.UnRegisterHandler "doubleClick"
	end if
end sub

sub buttonClick(item)
	'Toggles functionality
	mnu.Checked = not mnu.Checked
	playlocked = mnu.Checked
	toggleDoubleClick(mnu.Checked and SDB.player.isPlaying)
end sub

sub paused
	'Disables pause button if song is playing
	if playlocked and SDB.player.isPaused then
		SDB.Player.pause
	end if
end sub

sub played
	if playlocked then
		toggleDoubleClick(true)
	end if
end sub

sub finished
	if playlocked then
		'Need a timer for avoiding weird error message
		set ftimer = SDB.CreateTimer(50)
		Script.RegisterEvent ftimer, "OnTimer", "finishedTimer"
	end if
end sub

sub finishedTimer(timer)
	'Testing to see if stop after current is off
	if not SDB.player.isPlaying then
		toggleDoubleClick(false)
	end if
	Script.UnRegisterEvents timer
end sub

sub doubleClick(track)
	'Creating an event for double click seems to disable its normal behaviour.
	'This might be a bug, and might be fixed in later versions
end sub