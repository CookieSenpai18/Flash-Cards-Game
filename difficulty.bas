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
	Private b1n As Button
	Private b2 As Button
	Private b2n As Button
	Private b3 As Button
	Private b3n As Button
	Private eal As Panel
	Private harl As Panel
	Private medl As Panel
	Private menu As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("diff")
	menu.Color = Colors.ARGB(0, 0, 0, 0)

End Sub

Sub Activity_Resume
Main.bg1.play
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Private Sub b3n_Click
	Main.cl1.play
	eal.Visible = False
	medl.Visible = False
	harl.Visible = True
	harl.BringToFront
	Sleep(2500)
	harl.Visible = False
End Sub

Private Sub b3_Click
	Main.cl1.play
	StartActivity(loading)
	Main.mods = "hard"
	Main.ldl = "Ahh... I see.. So you want problems huh..."
	Activity.Finish
End Sub

Private Sub b2n_Click
	Main.cl2.play
	eal.Visible = False
	harl.Visible = False
	medl.Visible = True
  	medl.BringToFront
	Sleep(2500)
	medl.Visible = False
End Sub

Private Sub b2_Click
	Main.cl1.play
	StartActivity(loading)
	Main.mods = "medium"
	Main.ldl = "Interesting.. So you want some challenge huh?"
	Activity.Finish
End Sub

Private Sub b1n_Click
	Main.cl2.play
	medl.Visible = False
	harl.Visible = False
	eal.Visible = True
	eal.BringToFront
	Sleep(2500)
	eal.Visible = False

End Sub

Private Sub b1_Click
	Main.cl1.play
	StartActivity(loading)
	Main.mods = "game"
	Main.ldl = "Playing in Normal mode was a smart choice"
	Activity.Finish
End Sub

Private Sub menu_Click
	Main.cl2.play
	StartActivity(Main)
	Activity.Finish
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Main.cl2.play
		StartActivity(Main)
		Activity.Finish
	End If
	Return False ' Let the system handle other keys
End Sub

