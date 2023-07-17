#tag Module
Protected Module SOSMapsConstants
	#tag Note, Name = README
		
		Usage
		
		To use this control, you will need an Apple Developer account
		
		You will need to create an Maps ID for your website:
		1. go to your developer account
		2. Click on Certificates, Identifiers & Profiles
		3. Select Identifiers
		4. click the + button
		5. Scroll to the bottom and select Maps ID
		6. give it a name and reverse domain identifier (like maps.com.example)
		
		Next, you need a Maps JS key. 
		1. go to your developer account
		2. click on Certificates, IDs & Profiles
		3. select Keys
		4. click the + button
		5. Name the key and select Mapkit JS from the list
		6. Click the Configure button and select the Maps ID you created above
		7. Click Continue
		8. Click Register
		9. Click Download
		10. copy the Key ID and your developer ID 
		
		SAVE THIS KEY IN A SAFE PLACE. More information can be found on Apple's website:
		https://developer.apple.com/documentation/mapkitjs/creating_a_maps_identifier_and_a_private_key
		
		Add to your project
		1. Copy the folder called Copy These Files to your project
		2. Set the constants in SOSMapsConstants to match the KeyID and DeveloperID from above
		3. Copy the two CopyFilesSteps from this project into yours. One for the JWT signers and one for your p8 file. Make sure any missing files have been resolved.
		
		Mapkit tokens will be created on-the-fly by your app as needed
	#tag EndNote


	#tag Constant, Name = kTokenExpMinutes, Type = String, Dynamic = False, Default = \"1440", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kTokenKeyID, Type = String, Dynamic = False, Default = \"U76534J476", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kTokenTeamID, Type = String, Dynamic = False, Default = \"H6JJNL5AF3", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
