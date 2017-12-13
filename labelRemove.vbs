dim UI : Set UI = SDB.UI
dim mnu
dim tb
dim window
dim cancelBtn
dim okBtn
dim dropMenu
dim textField

sub OnStartup
	'Create a new toolbar section, in the main toolbar
	set tb = UI.AddToolbar("Extra Tools 2")
	' UI.AddMenuItemSep UI.Menu_TbStandard, 1, 5
	'Adding the button to the toolbar
	Set mnu = UI.addMenuItem(tb, 1, 3)
	'button name?
	mnu.Caption = "RemoveLabel"
	'Registering function to button click
	Script.RegisterEvent mnu, "OnClick", "buttonClick"
	'Set icon
	mnu.IconIndex = 8'SDB.RegisterIcon("Scripts\Auto\remove-icon.ico", 0)
	'Description
	mnu.Hint = "Remove a label from selected songs"



	'Creating input window
	Set window = SDB.UI.NewForm
	window.Common.SetRect 100, 100, 295, 110
	window.Caption = "Remove label"
	
	'Cancel button
	Set cancelBtn = SDB.UI.NewButton(window)
	cancelBtn.Caption = "Close"
	cancelBtn.Common.SetRect 170, 10, 100, 20
	cancelBtn.cancel = true

	'OK button
	Set okBtn = SDB.UI.NewButton(window)
	okBtn.Caption = "OK"
	okBtn.Common.SetRect 170, 40, 100, 20
	okBtn.default = true

	'Dropdown field selection
	set dropMenu = sdb.ui.newDropdown(window)
	dropMenu.style = 2
	dropMenu.common.setRect 10, 10, 150, 20
	dropMenu.addItem("Mood")
	dropMenu.addItem("Occasion")
	dropMenu.itemIndex = 0

	'text input field
	set textField = sdb.ui.newEdit(window)
	textField.common.setRect 10, 40, 150, 20

	'Registering events
	Script.RegisterEvent okBtn, "OnClick", "okBtnClick"
	cancelBtn.modalResult = 0
	okBtn.modalResult = 1
end sub

'Opening form
sub buttonClick(item)
	if sdb.currentSongList.count <> 0 then
		window.ShowModal
	end if
end sub

'Hitting ok button
sub okBtnClick
	dim list, itm, i, tmp, labelList
	set list = SDB.CurrentSongList
	if textField.text <> "" and list.count <> 0 then
		' Process all selected tracks
		if dropMenu.text = "Mood" then
			for i = 0 to list.count - 1
				Set itm = list.item(i)
				labelList = split(itm.mood, ";")
				itm.mood = ""
				for each label in labelList
					if trim(label) <> trim(textField.text) then
						if itm.mood <> "" then
							itm.mood = itm.mood & "; " & trim(label)
						else
							itm.mood = trim(label)
						end if
					end if
				next
			next
		elseif dropMenu.text = "Occasion" then
			for i = 0 to list.count - 1
				Set itm = list.item(i)
				labelList = split(itm.occasion, ";")
				itm.occasion = ""
				for each label in labelList
					if trim(label) <> trim(textField.text) then
						if itm.occasion <> "" then
							itm.occasion = itm.occasion & "; " & trim(label)
						else
							itm.occasion = trim(label)
						end if
					end if
				next
			next
		end if
	end if
	
	' Write all back to DB and update tags
	list.UpdateAll
end sub