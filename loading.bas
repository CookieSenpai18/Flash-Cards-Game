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

	Private prog As ProgressBar
	Private l1 As Label
	Private logos As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("lss")
	prog.Progress = 0


	' Set red progress drawable (only works with Horizontal style)
	Dim bg As ColorDrawable
	bg.Initialize(Colors.ARGB(195, 173, 216, 230), 10dip) ' Light blue with 50% opacity
	prog.Background = bg



	' Set red progress drawable (only works with Horizontal style)

l1.Text = Main.ldl

	StartProgress
	


End Sub

Sub StartProgress
	For i = 0 To 100
		prog.Progress = i
		Sleep(50)
	Next
	
	If prog.Progress = 100 Then
		If Main.mods = "game" Or Main.mods = "medium" Or Main.mods = "hard" Then
			Main.bg1.Stop
			Main.bg2.play
		End If
	
		StartActivity(Main.mods)
		Main.mods = ""
		Main.ldl = "Please Wait..."
		
		Activity.Finish
		
	End If
	
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub
