dim UI : Set UI = SDB.UI

dim mnu
dim tb
dim genre()
dim color()

'Trims spaces and tabs in front and after the string
Function MultilineTrim(Byval TextData)
	'Function taken from somewhere.
	'Any reason to make a new?
	Dim textRegExp
	Set textRegExp = new regexp
	textRegExp.Pattern = "\s{0,}(\S{1}[\s,\S]*\S{1})\s{0,}"
	textRegExp.Global = False
	textRegExp.IgnoreCase = True
	textRegExp.Multiline = True
	
	If textRegExp.Test(TextData) Then
		MultilineTrim = textRegExp.Replace (TextData, "$1")
	Else
		MultilineTrim = ""
	End If
End Function

'Turns a hex string to a dec number
function strhextonum(str)
	'MsgBox str, 4, 4
	num = CLng("&h" & str)
	'Need to convert from rrggbb to bbggrr
	sep = 16*16
	sep2 = sep*sep
	rr = Int(num/sep2)
	num = num - rr*sep2
	gg = Int(num/sep)
	bb = num - sep*gg
	'Assembles new number
	strhextonum = bb*sep2 + gg*sep + rr
end function

sub OnStartup
	'============================================
	' Toolbar button
	'============================================
	'Creates or gets the toolbar
	set tb = UI.AddToolbar("Extra Tools 2")
	
	'Create a new toolbar section, in the main toolbar
	' UI.AddMenuItemSep UI.Menu_TbStandard, 1, 2
	'Adding the button to the toolbar
	Set mnu = UI.addMenuItem(tb, 1, 1)
	'button name?
	mnu.Caption = "Colorcode"
	'Registering function to button click
	Script.RegisterEvent mnu, "OnClick", "colorCodeClick"
	'Set icon
	mnu.IconIndex = 39
	'Description
	mnu.Hint = "Color Coding tracks based on genre"
	
	'============================================
	' Read color file
	'============================================
	
	Set fileHandler = CreateObject("Scripting.FileSystemObject")
	
	'Get filepath
	Dim pathnodes : pathnodes = Split(Script.scriptPath, "\")
	for i = 0 to UBound(pathnodes) - 1
		path = path & pathnodes(i) & "\"
	next
	
	'Get data file
	Set file = fileHandler.openTextFile(path & "color.txt")
	
	'Splits each line, using : as separator, and trims spaces
	i = 0
	do until file.AtEndOfStream
		'Increment array length, while keeping values
		redim preserve genre(i)
		redim preserve color(i)
		
		'Read a line from file
		line = file.readLine
		
		'Skips empty lines and coments
		if not MultilineTrim(line) = "" and not Left(line, 1) = "#" then
			'Splits the line into segmets separated by :
			splt = Split(line, ":")
			genre(i) = MultilineTrim(splt(0))
			tmpColor = MultilineTrim(splt(1))
			'If color is a variable, then find it
			if Left(tmpColor, 1) = "&" then
				'Color is black if the variable was not found
				color(i) = 0
				tmpColor = Right(tmpColor, Len(tmpColor) - 1)
				for j = 0 to i - 1
					'strips away leading &
					if tmpColor = genre(j) then
						color(i) = color(j)
						exit for
					end if
				next
			else
				'Color is a string, needs to be converted to a number
				color(i) = strhextonum(tmpColor)
			end if
			i = i + 1
		end if
	loop
	file.Close

	'============================================
	' Extra
	'============================================
	'Registering changing playlist event
	Script.RegisterEvent SDB, "OnNowPlayingModified", "update"
end sub

sub removeColorTracks
	'Resetting everything to black
	set list = SDB.Player.CurrentPlaylist
	for i = 0 to list.Count - 1
		set itm = list.Item(i)
		itm.Color = 0
	next
end sub

sub colorTracks
	dim list
	dim itm
	dim genreBulk
	dim genreList
	dim curgen
	
	n = UBound(genre)
	'Testing purposes
	'dim tmp: tmp = "" & n
	'for i = 0 to n
	'	tmp = tmp & vbNewLine & genre(i) & " " & color(i)
	'next
	'MsgBox tmp

	'Gets a list of the songs in the now playing field
	set list = SDB.Player.CurrentPlaylist
	for i = 0 to list.Count - 1
		set itm = list.Item(i)
		genreBulk = itm.Genre
		genreList = Split(genreBulk, "; ")
		done = false
		'Finds the first genre which has an associated color,
		'and adds that color
		for each curgen in genreList
			for j = 0 to n
				if strComp(curgen, genre(j)) = 0 then
					itm.Color = color(j)
					'If found a color, end search
					done = true
					exit for
				end if
			next
			if done then exit for
		next
	next
end sub

sub colorCodeClick(item)
	if mnu.Checked then
		removeColorTracks
	else
		colorTracks
	end if
	mnu.Checked = not mnu.Checked
end sub

sub update
	if mnu.Checked then
		colorTracks
	end if
end sub