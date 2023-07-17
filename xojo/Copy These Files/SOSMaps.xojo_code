#tag Module
Protected Module SOSMaps
	#tag Method, Flags = &h1
		Protected Function RequiredLibraries() As String()
		  // This must be available BEFORE any sessions are created 
		  // because the values are sent to apple's servers as the page loads
		  
		  Dim libraries() As String
		  libraries.Add "map"
		  If EnableAnnotations Then libraries.Add "annotations"
		  If EnableFullMap Then libraries.Add "full-map"
		  If EnableGeoJSON Then libraries.add "geojson"
		  If EnableOverlays Then libraries.Add "overlays"
		  If EnableServices Then libraries.Add "services"
		  If EnableUserLocation Then libraries.add "user-location"
		  
		  Return libraries
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		EnableAnnotations As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		EnableFullMap As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		EnableGeoJSON As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		EnableOverlays As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		EnableServices As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		EnableUserLocation As Boolean
	#tag EndProperty


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
		#tag ViewProperty
			Name="EnableAnnotations"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="EnableFullMap"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="EnableGeoJSON"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="EnableOverlays"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="EnableServices"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="EnableUserLocation"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
