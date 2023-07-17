#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyP8File1
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 0
					Subdirectory = 
				End
				Begin CopyFilesBuildStep CopySigners1
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 0
					Subdirectory = 
					FolderItem = Li4vLi4vZ28vZGlzdC8=
				End
			End
			Begin BuildStepList Mac OS X
				Begin IDEScriptBuildStep LoadJSScript , AppliesTo = 0, Architecture = 0, Target = 0
					Dim txt As String
					txt  = LoadText("/Users/gregolon/Work/Git/xojo_web_mapkit/javascript/dist/sosmapkit.js")
					
					ConstantValue("SOSMapKit.kJavascriptControlCode") = txt
				End
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopySigners
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 0
					Subdirectory = 
					FolderItem = Li4vLi4vZ28vZGlzdC8=
				End
				Begin CopyFilesBuildStep CopyP8File
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 0
					Subdirectory = 
					FolderItem = Li4vLi4vLi4vLi4vLi4vRG93bmxvYWRzL01hcHNKU19BdXRoS2V5X1U3NjUzNEo0NzYucDg=
				End
				Begin SignProjectStep Sign
				  DeveloperID=
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyP8File
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 0
					Subdirectory = 
				End
				Begin CopyFilesBuildStep CopySigners
					AppliesTo = 0
					Architecture = 0
					Target = 0
					Destination = 0
					Subdirectory = 
					FolderItem = Li4vLi4vZ28vZGlzdC8=
				End
			End
			Begin BuildStepList Xojo Cloud
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
