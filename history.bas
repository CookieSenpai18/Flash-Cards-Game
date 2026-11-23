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
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private b1 As Button
	Private lview As ListView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("history")
	b1.Color = Colors.ARGB(0, 0, 0, 0)
		
	lview.SingleLineLayout.ItemHeight =30dip
	lview.SingleLineLayout.Label.TextSize = 12
	lview.SingleLineLayout.Label.TextColor = Colors.Black
	lview.SingleLineLayout.Label.Typeface = Typeface.MONOSPACE
		
	If lview.Size > 20 Then
		lview.RemoveAt(20)
	End If
		

	Main.bg1.Play
		
		


End Sub

Sub Activity_Resume
	If Main.bg1.IsPlaying = False Then
		Main.bg1.play
	End If
	
	lview.Clear


	Dim reversedList As List
	reversedList.Initialize

	' Copy items in reverse order
	For i = Main.datlist.Size - 1 To 0 Step -1
		reversedList.Add(Main.datlist.Get(i))
	Next
	For Each line As String In Main.datlist
		Dim parts() As String = Regex.Split(",", line)
		If parts.Length >= 4 Then
			Dim name As String = parts(0)
			Dim diff As String = parts(1)
			Dim time As String = parts(2)
			Dim score As String = parts(3)
			Dim lbl2 As String = name & "      " & diff & "      " & time & "         " & score
			lview.AddSingleLine( lbl2)
		End If
	Next
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	Main.bg1.pause

End Sub


Private Sub b1_Click
	Main.cl1.play
	StartActivity("Main")
	Activity.Finish
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Main.cl1.play
		Activity.Finish
	End If
	Return False ' Let the system handle other keys
End Sub