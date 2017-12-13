dim UI : Set UI = SDB.UI
dim mnu
dim tb

sub OnStartup
	'Create a new toolbar section, in the main toolbar
	set tb = UI.AddToolbar("Extra Tools")
	' UI.AddMenuItemSep UI.Menu_TbStandard, 1, 1
	'Adding the button to the toolbar
	Set mnu = UI.addMenuItem(tb, 1, 1)
	'button name?
	mnu.Caption = "StopAfterCurrent"
	'Registering function to button click
	Script.RegisterEvent mnu, "OnClick", "buttonClick"
	'Set icon
	mnu.IconIndex = 2
	'Description
	mnu.Hint = "Enables stop after current"

	'Registering events to make sure stop after current setting
	'is always up to date
	Script.RegisterEvent SDB, "OnPlay", "update"
	Script.RegisterEvent SDB, "OnPause", "update"
	Script.RegisterEvent SDB, "OnPlaybackEnd", "update"
end sub

sub buttonClick(item)
	mnu.Checked = not mnu.Checked
	SDB.Player.StopAfterCurrent = mnu.Checked
end sub

sub update
	SDB.Player.StopAfterCurrent = mnu.Checked
end sub