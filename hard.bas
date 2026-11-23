B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=13.1
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: true
	#IncludeTitle: false
	
#End Region

Sub Process_Globals
	Private xui As XUI
	
	
End Sub

Sub Globals

	Dim Buttons As List
	' Declare a global bitmap to hold the back image
	Dim BackImage As Bitmap
	Dim ButtonToImage As Map ' Maps Button -> ImageName
	Dim FirstSelected As Button
	Dim SecondSelected As Button
	Dim IsBusy As Boolean
	Dim ButtonWidth As Int
	Dim TimerCount As Int = 300 ' total seconds (10 minutes)
	Dim CountDownTimer As Timer
	Dim Mistakes As Int
	Private StartTime As Long= DateTime.Now
	Private EndTime As Long= DateTime.Now
	Dim CumulativeStrike As Int
	Dim ElapsedSeconds As Int = 0
	Dim TotalTime As Int = 300
	Dim Score As Int = 0
	Dim ScorePenaltyCounter As Int = 0
	Dim secondsSinceFlipBack As Int = 0
	Dim IsMatched(31) As Boolean
	Dim bmp As Bitmap = LoadBitmap(File.DirAssets, "back.png")
	Dim MatchedPairsQueue As List ' stores pairs as a two-element Int array (button indices)
	Dim MatchedPairsFlippedBackCount As Int = 0


	
	Private l1 As Label
	' Your 30 buttons
	Private bt1, bt2, bt3, bt4, bt5, bt6, bt7, bt8, bt9, bt10 As Button
	Private bt11, bt12, bt13, bt14, bt15, bt16, bt17, bt18, bt19, bt20 As Button
	Private bt21, bt22, bt23, bt24, bt25, bt26, bt27, bt28, bt29, bt30 As Button
	Private scor As Label
	Private otp As Label
	Private go As Panel
	Private nexl As Button
	Private menu As Button
	Private notif As Panel
	Private timu As Panel
	Private cong As Panel
	
End Sub


Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("card_game")
	nexl.Color = Colors.ARGB(0, 0, 0, 0)
	ButtonToImage.Initialize
	ButtonWidth  = bt1.Width
	LoadButtons
	LoadBackImage
	HideAllCards
	AssignRandomImages
	l1.Text = "00:00"
	MatchedPairsQueue.Initialize

Main.bg2.play
	' Initialize timer
	CountDownTimer.Initialize("CountDownTimer", 1000) ' ticks every 1 second
	UpdateTimerLabel ' show initial time 10:00
	CountDownTimer.Initialize("CountDownTimer", 1000) ' fires every 1 second
	CountDownTimer.Enabled = True

	StartTime = DateTime.Now
	Mistakes = 0
	CumulativeStrike = 0
	StartTime = DateTime.Now
	Score = 0
	scor.Text = "Score: 0"
	scor.Text = "Score: 0"
	scor.TextColor = Colors.red
	scor.TextSize = 20
	scor.Typeface = Typeface.DEFAULT_BOLD
	scor.Gravity = Gravity.CENTER



	snd
End Sub
Sub snd
	Sleep(300)
	ShowAllCardsTemporarily
	Main.flip1.play
End Sub

Sub FlipBackMatchedCards
	IsBusy=True
	If MatchedPairsQueue.Size > 0 Then
		Dim pair() As Int = MatchedPairsQueue.Get(0)
		MatchedPairsQueue.RemoveAt(0)

		Dim index1 As Int = pair(0)
		Dim index2 As Int = pair(1)

		' Get buttons
		Dim btn1 As Button = Buttons.Get(index1 - 1)
		Dim btn2 As Button = Buttons.Get(index2 - 1)

		' Flip back animations using updated FlipBack (preserves size)
		FlipBack(btn1)
		FlipBack(btn2)
		Sleep(200)

		' Re-enable and update match tracking
		btn1.Enabled = True
		btn2.Enabled = True
		IsMatched(index1) = False
		IsMatched(index2) = False

		' Shuffle their images with random unmatched cards
		ReshuffleUnmatchedCards
	End If
	Sleep(300)
	IsBusy=False
End Sub


Sub ReshuffleUnmatchedCards
	Dim unmatchedIndices As List
	unmatchedIndices.Initialize

	For i = 1 To Buttons.Size
		Dim btn As Button = Buttons.Get(i - 1)
		If Not(IsMatched(i)) And btn.Enabled Then
			unmatchedIndices.Add(i)
		End If
	Next

	Dim positions As List
	positions.Initialize

	For Each idx As Int In unmatchedIndices
		Dim btn As Button = Buttons.Get(idx - 1)
		positions.Add(Array As Int(btn.Left, btn.Top)) ' Still fine to add as Array
	Next

	ShuffleList(positions)

	For i = 0 To unmatchedIndices.Size - 1
		Dim idx As Int = unmatchedIndices.Get(i)
		Dim btn As Button = Buttons.Get(idx - 1)

		Dim pos() As Int = positions.Get(i) ' ✅ FIXED LINE
		Dim x As Int = pos(0)
		Dim y As Int = pos(1)

		btn.Left = x
		btn.Top = y
	Next
End Sub




Sub ShuffleCards(index1 As Int, index2 As Int)
	Dim random1 As Int = GetRandomUnmatchedIndex2(index1)
	Dim random2 As Int = GetRandomUnmatchedIndex3(index1, index2)

	If CountUnmatchedCards < 4 Then Return ' too few to shuffle safely

	If random1 = -1 Or random2 = -1 Then Return ' Not enough unmatched cards

	' Swap images in the map
	Dim tempImage1 As String = ButtonToImage.Get(index1)
	Dim tempImage2 As String = ButtonToImage.Get(index2)

	ButtonToImage.Put(index1, ButtonToImage.Get(random1))
	ButtonToImage.Put(index2, ButtonToImage.Get(random2))

	ButtonToImage.Put(random1, tempImage1)
	ButtonToImage.Put(random2, tempImage2)

	' Now swap actual button positions
	Dim btn1 As Button = Buttons.Get(index1 - 1)
	Dim btn2 As Button = Buttons.Get(index2 - 1)
	Dim btn3 As Button = Buttons.Get(random1 - 1)
	Dim btn4 As Button = Buttons.Get(random2 - 1)

	' Swap positions
	SwapButtonPosition(btn1, btn3)
	SwapButtonPosition(btn2, btn4)

	' Flip all to back
	btn1.SetBackgroundImage(bmp)
	btn2.SetBackgroundImage(bmp)
	btn3.SetBackgroundImage(bmp)
	btn4.SetBackgroundImage(bmp)

	btn1.Enabled = True
	btn2.Enabled = True
	btn3.Enabled = True
	btn4.Enabled = True
End Sub
Sub CountUnmatchedCards As Int
	Dim count As Int = 0
	For i = 1 To 30
		If IsMatched(i) = False Then count = count + 1
	Next
	Return count
End Sub

Sub SwapButtonPosition(btnA As Button, btnB As Button)
	Dim duration As Int = 300
	Dim btnALeft As Int = btnA.Left
	Dim btnATop As Int = btnA.Top
	Dim btnBLeft As Int = btnB.Left
	Dim btnBTop As Int = btnB.Top
    
	btnA.SetLayoutAnimated(duration, btnBLeft, btnBTop, btnA.Width, btnA.Height)
	btnB.SetLayoutAnimated(duration, btnALeft, btnATop, btnB.Width, btnB.Height)
    
	Sleep(duration)
End Sub



Sub GetRandomUnmatchedIndex2(exclude1 As Int) As Int
	Dim candidates As List
	candidates.Initialize

	For i = 1 To 30
		If IsMatched(i) = False And i <> exclude1 Then
			Dim btn As Button = Buttons.Get(i - 1)
			If btn <> FirstSelected And btn <> SecondSelected And IsIndexInMatchedQueue(i) = False Then
				candidates.Add(i)
			End If
		End If
	Next

	If candidates.Size = 0 Then Return -1

	Return candidates.Get(Rnd(0, candidates.Size))
End Sub

Sub GetRandomUnmatchedIndex3(exclude1 As Int, exclude2 As Int) As Int
	Dim candidates As List
	candidates.Initialize

	For i = 1 To 30
		If IsMatched(i) = False And i <> exclude1 And i <> exclude2 Then
			Dim btn As Button = Buttons.Get(i - 1)
			If btn <> FirstSelected And btn <> SecondSelected And IsIndexInMatchedQueue(i) = False Then
				candidates.Add(i)
			End If
		End If
	Next

	If candidates.Size = 0 Then Return -1

	Return candidates.Get(Rnd(0, candidates.Size))
End Sub

Sub IsIndexInMatchedQueue(index As Int) As Boolean
	For Each pair() As Int In MatchedPairsQueue
		If pair(0) = index Or pair(1) = index Then
			Return True
		End If
	Next
	Return False
End Sub




Sub AnimateScoreLabel(lbl As Label)
	If Score <= 0 Then
		scor.TextColor = Colors.Red
	Else
		scor.TextColor = Colors.Green
	End If
	Dim duration As Int = 200
	lbl.SetLayoutAnimated(duration, lbl.Left - 10dip, lbl.Top - 10dip, lbl.Width + 15dip, lbl.Height + 15dip)
	Sleep(duration)
	lbl.SetLayoutAnimated(duration, lbl.Left + 10dip, lbl.Top + 10dip, lbl.Width - 15dip, lbl.Height - 15dip)
End Sub
Sub ShowAllCardsTemporarily
	' Flip and show all card faces
	For i = 0 To Buttons.Size - 1
		Dim btn As Button = Buttons.Get(i)
		Dim originalWidth As Int = btn.Width
		Dim centerX As Int = btn.Left + originalWidth / 2
        
		' Flip-in animation to 1dip
		btn.SetLayoutAnimated(150, centerX - 0.5dip, btn.Top, 1dip, btn.Height)
		sc1
        
		' Set front image
		Dim imgName As String = ButtonToImage.Get(btn)
		btn.SetBackgroundImage(LoadBitmap(File.DirAssets, imgName))
        
		' Flip-out animation back to original width
		btn.SetLayoutAnimated(150, centerX - originalWidth / 2, btn.Top, originalWidth, btn.Height)
		btn.Enabled = False
	Next

	Sleep(3000)
	Main.flip2.play

	' Flip all cards back to hidden
	For i = 0 To Buttons.Size - 1
		Dim btn As Button = Buttons.Get(i)
		Dim originalWidth As Int = btn.Width
		Dim centerX As Int = btn.Left + originalWidth / 2

		' Flip-in to 1dip
		btn.SetLayoutAnimated(150, centerX - 0.5dip, btn.Top, 1dip, btn.Height)
		sc1
        
		btn.SetBackgroundImage(BackImage)
        
		' Flip-out back to original width
		btn.SetLayoutAnimated(150, centerX - originalWidth / 2, btn.Top, originalWidth, btn.Height)
		btn.Enabled = True
	Next
End Sub

Sub sc1
	Sleep(250)
End Sub




Sub CountDownTimer_Tick
	ElapsedSeconds = ElapsedSeconds + 1

	Dim RemainingSeconds As Int = TotalTime - ElapsedSeconds
	If RemainingSeconds < 0 Then RemainingSeconds = 0

	Dim minutes As Int = Floor(RemainingSeconds / 60)
	Dim seconds As Int = RemainingSeconds Mod 60
	l1.Text = NumberFormat(minutes, 2, 0) & ":" & NumberFormat(seconds, 2, 0)

	' Deduct 3 points every 15 seconds
	If ElapsedSeconds Mod 15 = 0 Then
		Score = Max(Score - 3, 0)
	End If

	If RemainingSeconds = 0 Then
		CountDownTimer.Enabled = False
		GameTerminator("timeout")
	End If
	
	UpdateTimerLabel
	secondsSinceFlipBack = secondsSinceFlipBack + 1

	If secondsSinceFlipBack >= 60 Then
		FlipBackMatchedCards
		secondsSinceFlipBack = 0
	End If

End Sub


Sub UpdateTimerLabel
	Dim RemainingSeconds As Int = TotalTime - ElapsedSeconds
	If RemainingSeconds < 60 Then
		l1.TextColor = Colors.Red
		WiggleLabel(l1)
	End If
	
	If RemainingSeconds < 10 Then
		BlinkLabelBackground(l1)
	End If
	
	If RemainingSeconds = 60 Then
		Main.tick.Play
	Else if RemainingSeconds = 10 Then
		Main.tick.Play
	else if RemainingSeconds = 0 Then
		Main.alarm.Play
	End If


End Sub
Sub BlinkLabelBackground(lbl As Label)
	Dim i As Int
	For i = 0 To 2
		lbl.Color = Colors.Red
		l1.textColor = Colors.black
		Sleep(150)
		lbl.Color = Colors.Transparent
		l1.textColor = Colors.red
		Sleep(150)
	Next
End Sub

Sub WiggleLabel(lbl As Label)
	Dim originalLeft As Int = lbl.Left
	Dim wiggleDistance As Int = 3dip
	lbl.SetLayoutAnimated(50, originalLeft - wiggleDistance, lbl.Top, lbl.Width, lbl.Height)
	Sleep(50)
	lbl.SetLayoutAnimated(50, originalLeft + wiggleDistance, lbl.Top, lbl.Width, lbl.Height)
	Sleep(50)
	lbl.SetLayoutAnimated(50, originalLeft, lbl.Top, lbl.Width, lbl.Height)
End Sub

Sub FormatTwoDigits(value As Int) As String
	If value < 10 Then
		Return "0" & value
	Else
		Return value
	End If
End Sub

Sub AssignRandomImages
	Dim TotalPairs As Int = 15
	Dim TotalImages As Int = 66
    
	Dim AvailableImages As List
	AvailableImages.Initialize
	Dim i As Int
	For i = 1 To TotalImages
		AvailableImages.Add("cards (" & i & ").png")
	Next
    
	ShuffleList(AvailableImages)
    
	Dim PairedImages As List
	PairedImages.Initialize
	For i = 0 To TotalPairs - 1
		Dim img As String = AvailableImages.Get(i)
		PairedImages.Add(img)
		PairedImages.Add(img)
	Next
    
	ShuffleList(PairedImages)
    
	For i = 0 To Buttons.Size - 1
		Dim btn As Button = Buttons.Get(i)
		ButtonToImage.Put(btn, PairedImages.Get(i))
		btn.SetBackgroundImage(BackImage)
	Next
End Sub
Sub ShuffleList(lst As List)
	Dim i, j As Int
	Dim temp As Object
	Dim listSize As Int = lst.Size
	'Randomize
	For i = listSize - 1 To 1 Step -1
		j = Rnd(0, i + 1)
		temp = lst.Get(i)
		lst.Set(i, lst.Get(j))
		lst.Set(j, temp)
	Next
End Sub
Sub GameTerminator(reason As String)
	
	' Stop timer
	CountDownTimer.Enabled = False

	' Disable all buttons
	For Each btn As Button In Buttons
		btn.Enabled = False
	Next

	Dim timeTaken As Int = ElapsedSeconds
	Dim minutes As Int = Floor(timeTaken / 60)
	Dim seconds As Int = timeTaken Mod 60
	Dim timeStr As String = NumberFormat(minutes, 2, 0) & ":" & NumberFormat(seconds, 2, 0)
	If reason = "timeout" Then
		timu.Visible=True
		timu.BringToFront
		cong.Visible=False
		AnimateGovToMiddle
		Sleep(3000)
	End If
	Dim message As String
	If reason = "completed" Then
		message = $"Game Completed! 🎉
Mistakes made: ${Mistakes}
Time taken: ${timeStr}
Max strike count: ${CumulativeStrike}
Final Score: ${Score}"$

	Else If reason = "timeout" Then
		message = $"Time's up! ⏰
Mistakes made: ${Mistakes}
Time reached: ${timeStr}
Final Score: ${Score}"$

	Else
		message = "Game Over."
	End If
	
	go.BringToFront
	go.SetVisibleAnimated(1800, True)
	go.Visible = True
	otp.Text = message
	
	
	Dim dif As String = "Extreme"
	Main.tim = timeStr
	Main.sc = Score
	If reason = "completed" Then
		Dim entry As String = Main.usr & "," & dif & "," & Main.tim & "," & Main.sc
		Main.datlist.Add(entry)
		File.WriteList(File.DirInternal, "history.txt", Main.datlist)
	End If
	
End Sub
Sub AnimateGovToMiddle
	' Make sure the panel starts off-screen at the top
	notif.Top = -notif.Height

	' Show the panel
	notif.Visible = True

	' Animate to the middle of the screen over 500ms
	Dim middleY As Int = (80%y - timu.Height) / 2
	notif.SetLayoutAnimated(2500, notif.Left, middleY, notif.Width, notif.Height)
End Sub





Sub Button_Click(btn As Button)

	If IsBusy Or btn = FirstSelected Then Return
	Main.flip3.Play

	If ButtonToImage.IsInitialized = False Or ButtonToImage.ContainsKey(btn) = False Then
		Return
	End If

	IsBusy = True

	Dim originalWidth As Int = btn.Width
	Dim centerX As Int = btn.Left + originalWidth / 2

	' Shrink width centered (simulate 3D flip)
	btn.SetLayoutAnimated(150, centerX - 0.5dip, btn.Top, 1dip, btn.Height)
	Sleep(150)

	' Show image
	Dim imgName As String = ButtonToImage.Get(btn)
	btn.SetBackgroundImage(LoadBitmap(File.DirAssets, imgName))

	' Expand width centered back to original size
	btn.SetLayoutAnimated(150, centerX - originalWidth / 2, btn.Top, originalWidth, btn.Height)
	Sleep(150)

	If FirstSelected = Null Or FirstSelected.IsInitialized = False Then
		FirstSelected = btn
		IsBusy = False
	Else
		SecondSelected = btn
		SleepAndCheck
	End If
End Sub


Sub FlipBack(btn As Button)
	Main.flip1.Play

	' Capture fixed centerX, top, and original width at start
	Dim originalWidth As Int = btn.Width
	Dim centerX As Int = btn.Left + originalWidth / 2
	Dim top As Int = btn.Top

	' Animate to 1dip width (flip in)
	btn.SetLayoutAnimated(150, centerX - 0.5dip, top, 1dip, btn.Height)
	Sleep(150)

	' Change to card back
	btn.SetBackgroundImage(BackImage)

	' Animate back to original width (flip out)
	btn.SetLayoutAnimated(150, centerX - originalWidth / 2, top, originalWidth, btn.Height)
	Sleep(150)
End Sub



Sub SleepAndCheck
	Sleep(1000)

	If ButtonToImage.Get(FirstSelected) = ButtonToImage.Get(SecondSelected) Then
		FirstSelected.Enabled = False
		SecondSelected.Enabled = False
		Dim cardIndex1 As Int = Buttons.IndexOf(FirstSelected) + 1 ' +1 if your array is 1-based
		Dim cardIndex2 As Int = Buttons.IndexOf(SecondSelected) + 1

		IsMatched(cardIndex1) = True
		IsMatched(cardIndex2) = True

		Dim pair(2) As Int
		pair(0) = Buttons.IndexOf(FirstSelected) + 1
		pair(1) = Buttons.IndexOf(SecondSelected) + 1
		MatchedPairsQueue.Add(pair)

		' Reset strike count because of correct match
		CumulativeStrike = 0

		' Add score for correct pair
		Score = Score + 10
		scor.Text = $"Score: ${Score}"$

		If Score <= 0 Then
			scor.TextColor = Colors.Red
		Else
			scor.TextColor = Colors.Green
			AnimateScoreLabel(scor)
		End If




		' Check if all buttons are disabled
		Dim allDisabled As Boolean = True
		For Each btn As Button In Buttons
			If btn.Enabled Then
				allDisabled = False
				Exit
			End If
		Next

		If allDisabled Then
			EndTime = DateTime.Now
			GameTerminator("completed")
		End If

	Else
		' Increment mistakes and strike count for wrong match
		Mistakes = Mistakes + 1
		CumulativeStrike = CumulativeStrike + 1

		' Deduct score for wrong match but never below zero
		Score = Max(Score - 5, 0)
		scor.Text = $"Score: ${Score}"$
		
		If Score <= 0 Then
			scor.TextColor = Colors.Red
		Else
			scor.TextColor = Colors.Green
			AnimateScoreLabel(scor)
		End If
		
		' Flip both cards back after a short delay
		FlipBack(FirstSelected)
		FlipBack(SecondSelected)
		Sleep(300)
	End If
	
	' Reset selections
	FirstSelected = Null
	SecondSelected = Null
	IsBusy = False
End Sub









Sub GetButton(i As Int) As Button
	Select i
		Case 1: Return bt1
		Case 2: Return bt2
		Case 3: Return bt3
		Case 4: Return bt4
		Case 5: Return bt5
		Case 6: Return bt6
		Case 7: Return bt7
		Case 8: Return bt8
		Case 9: Return bt9
		Case 10: Return bt10
		Case 11: Return bt11
		Case 12: Return bt12
		Case 13: Return bt13
		Case 14: Return bt14
		Case 15: Return bt15
		Case 16: Return bt16
		Case 17: Return bt17
		Case 18: Return bt18
		Case 19: Return bt19
		Case 20: Return bt20
		Case 21: Return bt21
		Case 22: Return bt22
		Case 23: Return bt23
		Case 24: Return bt24
		Case 25: Return bt25
		Case 26: Return bt26
		Case 27: Return bt27
		Case 28: Return bt28
		Case 29: Return bt29
		Case 30: Return bt30
		Case Else: Return Null
	End Select
End Sub



Sub LoadButtons
	Buttons.Initialize
	Buttons.Add(bt1)
	Buttons.Add(bt2)
	Buttons.Add(bt3)
	Buttons.Add(bt4)
	Buttons.Add(bt5)
	Buttons.Add(bt6)
	Buttons.Add(bt7)
	Buttons.Add(bt8)
	Buttons.Add(bt9)
	Buttons.Add(bt10)
	Buttons.Add(bt11)
	Buttons.Add(bt12)
	Buttons.Add(bt13)
	Buttons.Add(bt14)
	Buttons.Add(bt15)
	Buttons.Add(bt16)
	Buttons.Add(bt17)
	Buttons.Add(bt18)
	Buttons.Add(bt19)
	Buttons.Add(bt20)
	Buttons.Add(bt21)
	Buttons.Add(bt22)
	Buttons.Add(bt23)
	Buttons.Add(bt24)
	Buttons.Add(bt25)
	Buttons.Add(bt26)
	Buttons.Add(bt27)
	Buttons.Add(bt28)
	Buttons.Add(bt29)
	Buttons.Add(bt30)
End Sub

Sub LoadBackImage
	Dim btnWidth As Int = bt1.Width ' Or your button width in pixels
	Dim btnHeight As Int = bt1.Height ' Or your button height in pixels
	BackImage = LoadBitmapResize(File.DirAssets, "back.png", btnWidth, btnHeight, True)
End Sub
Sub HideAllCards
	For Each btn As Button In Buttons
		btn.SetBackgroundImage(BackImage)
	Next
End Sub

Sub bt1_Click
	Button_Click(bt1)
End Sub

Sub bt2_Click
	Button_Click(bt2)
End Sub

Sub bt3_Click
	Button_Click(bt3)
End Sub

Sub bt4_Click
	Button_Click(bt4)
End Sub

Sub bt5_Click
	Button_Click(bt5)
End Sub

Sub bt6_Click
	Button_Click(bt6)
End Sub

Sub bt7_Click
	Button_Click(bt7)
End Sub

Sub bt8_Click
	Button_Click(bt8)
End Sub

Sub bt9_Click
	Button_Click(bt9)
End Sub

Sub bt10_Click
	Button_Click(bt10)
End Sub

Sub bt11_Click
	Button_Click(bt11)
End Sub

Sub bt12_Click
	Button_Click(bt12)
End Sub

Sub bt13_Click
	Button_Click(bt13)
End Sub

Sub bt14_Click
	Button_Click(bt14)
End Sub

Sub bt15_Click
	Button_Click(bt15)
End Sub

Sub bt16_Click
	Button_Click(bt16)
End Sub

Sub bt17_Click
	Button_Click(bt17)
End Sub

Sub bt18_Click
	Button_Click(bt18)
End Sub

Sub bt19_Click
	Button_Click(bt19)
End Sub

Sub bt20_Click
	Button_Click(bt20)
End Sub

Sub bt21_Click
	Button_Click(bt21)
End Sub

Sub bt22_Click
	Button_Click(bt22)
End Sub

Sub bt23_Click
	Button_Click(bt23)
End Sub

Sub bt24_Click
	Button_Click(bt24)
End Sub

Sub bt25_Click
	Button_Click(bt25)
End Sub

Sub bt26_Click
	Button_Click(bt26)
End Sub

Sub bt27_Click
	Button_Click(bt27)
End Sub

Sub bt28_Click
	Button_Click(bt28)
End Sub

Sub bt29_Click
	Button_Click(bt29)
End Sub

Sub bt30_Click
	Button_Click(bt30)
End Sub


Private Sub nexl_Click
	Main.cl1.play
	Main.bg2.stop
	StartActivity(loading)
	Main.mods = "hard"
	Activity.Finish
End Sub

Sub menu_click
	Main.cl1.play
	Dim resul As Int
	resul = Msgbox2("Are You Sure You Want to Return To Main Menu?", "Return To Main Menu", "Yes", "", "No", Null)
	If resul = DialogResponse.Positive Then
		Main.bg2.Stop
		Main.bg1.Initialize()
		Main.bg1.Load(File.DirAssets, "nbgm4.mp3")
		Main.bg1.SetVolume(Main.vl1, Main.vl1)
		Main.bg1.Looping = True
		CountDownTimer.Enabled = False
		Main.bg1.play
		StartActivity("loading")
		Main.mods = "Main"
		Activity.finish
	End If
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Main.cl1.play
		Dim resul As Int
		resul = Msgbox2("Are You Sure You Want to Return To Main Menu?", "Return To Main Menu", "Yes", "", "No", Null)
		If resul = DialogResponse.Positive Then
			Main.bg2.Stop
			Main.bg1.Initialize()
			Main.bg1.Load(File.DirAssets, "nbgm4.mp3")
			Main.bg1.SetVolume(Main.vl1, Main.vl1)
			Main.bg1.Looping = True
			CountDownTimer.Enabled = False
			Main.bg1.play
			StartActivity("loading")
			Main.mods = "Main"
			Activity.finish
		End If
	End If
	Return False ' Let the system handle other keys
End Sub