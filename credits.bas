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
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("credits")
	b1.Color = Colors.ARGB(0, 0, 0, 0)

End Sub

Sub Activity_Resume
Main.bg1.play
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Private Sub b1_Click
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