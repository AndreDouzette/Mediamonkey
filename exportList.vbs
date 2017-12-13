dim UI : Set UI = SDB.UI
dim mnu
dim tb

sub OnStartup
	'Create a new toolbar section
	set tb = UI.AddToolbar("Extra Tools")
	' UI.AddMenuItemSep tb, 1, 3
	'Adding the button to the toolbar
	Set mnu = UI.addMenuItem(tb, 1, 3)
	'button name?
	mnu.Caption = "SaveAsList"
	'Registering function to button click
	Script.RegisterEvent mnu, "OnClick", "buttonClick"
	'Set icon
	mnu.IconIndex = 56
	'Description
	mnu.Hint = "Exports now playing songs as a list"
end sub

sub buttonClick(item)
	'Create common dialog and ask where to save the file
	dim dlg: set dlg = SDB.CommonDialog
	dlg.DefaultExt = "txt"
	dlg.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
	dlg.Flags = cdlOFNOverwritePrompt + cdlOFNHideReadOnly
	dlg.InitDir = SDB.IniFile.StringValue("Scripts", iniDirValue)
	dlg.ShowSave
	
	'if cancel was pressed, exit
	If Not dlg.Ok Then
		Exit Sub
	End If
	
	' Get the selected filename
	dim fullfile: fullfile = dlg.FileName
	
	'Opens the selected file
	Set fileHandler = CreateObject("Scripting.FileSystemObject")
	Set file = fileHandler.createTextFile(fullfile, true)
	
	'Gets a list of the songs in the now playing field
	dim list
	dim itm
	dim bpm
	set list = SDB.Player.CurrentPlaylist
	for i = 0 to list.Count - 1
		set itm = list.Item(i)
		bpm = itm.BPM
		
		file.Write "Track:    " & CStr(i + 1)			& vbNewLine
		file.Write "Title:    " & itm.Title 			& vbNewLine
		file.Write "Artist:   " & itm.ArtistName		& vbNewLine
		file.Write "Album:    " & itm.AlbumName			& vbNewLine
		file.Write "Length:   " & itm.SongLengthString 	& vbNewLine
		if CInt(bpm) > 0 then
			file.Write "BPM:      " & bpm			& vbNewLine
		end if
		if i < list.Count - 1 then
			file.Write vbNewLine
		end if
	next
	file.Close
end sub