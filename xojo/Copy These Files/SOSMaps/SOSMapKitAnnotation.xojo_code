#tag Class
Class SOSMapKitAnnotation
	#tag Method, Flags = &h0
		Sub Constructor(latitude as double, longitude as double, title as string, c as color, subtitle as string = "", selected as boolean = true, glyph as string = "")
		  Self.Latitude = Latitude
		  Self.Longitude = longitude
		  Self.Title = title
		  Self.BackgroundColor = c
		  Self.Subtitle = subtitle
		  Self.Selected = selected
		  Self.Glyph = glyph
		  
		  self.mTag = EncodeHex(crypto.GenerateRandomBytes(32))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		BackgroundColor As Color
	#tag EndProperty

	#tag Property, Flags = &h0
		Glyph As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Latitude As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		Longitude As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTag As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Selected As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Subtitle As string
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mTag
			End Get
		#tag EndGetter
		Tag As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Visible As Boolean
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
			Name="Title"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Subtitle"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackgroundColor"
			Visible=false
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Glyph"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Selected"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Latitude"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Longitude"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Tag"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
