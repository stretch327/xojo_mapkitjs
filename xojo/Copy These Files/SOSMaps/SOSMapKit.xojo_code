#tag Class
Class SOSMapKit
Inherits WebSDKUIControl
	#tag Event
		Sub DrawControlInLayoutEditor(g as graphics)
		  // Even though it's just blue ocean, make it look like something in the IDE
		  
		  // Fill with blue ocean color
		  g.DrawingColor = &c8CDBF6
		  g.FillRectangle 0, 0, g.Width, g.Height
		  
		  // Insert the Maps overlay in the lower right corner followed by "Legal"
		  Dim overlay As picture = PictureConstant("kMapsOverlay")
		  
		  Dim h As Integer = overlay.Height
		  
		  g.DrawPicture overlay, 10, g.Height - h - 5
		  
		  g.Underline = True
		  
		  g.FontSize = 9
		  g.DrawingColor = &c22222277
		  g.DrawText "Legal", 5 + overlay.Width + 15, g.Height - 10
		  
		  
		  // Draw North Pacific Ocean in the middle of the map
		  g.Underline = False
		  g.DrawingColor = &c22222277
		  g.FontSize = 18
		  
		  Dim y As Integer = (g.Height - g.TextHeight)/2 + g.FontAscent
		  
		  g.DrawText "North", (g.Width - g.TextWidth("North"))/2, y-g.TextHeight
		  
		  g.DrawText "Pacific", (g.Width - g.TextWidth("Pacific"))/2, y
		  
		  g.DrawText "Ocean", (g.Width - g.TextWidth("Ocean"))/2, y+g.TextHeight
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function ExecuteEvent(name as string, parameters as JSONItem) As Boolean
		  Select Case name
		  Case "ready"
		    RaiseEvent Ready
		    mMapIsReady = True
		    UpdateControl
		  Case "clicked"
		    RaiseEvent clicked(parameters.Lookup("latitude", 0), parameters.Lookup("longitude", 0))
		  Case "error"
		    RaiseEvent Error(new RuntimeException(parameters.Value("message")))
		  End Select
		End Function
	#tag EndEvent

	#tag Event
		Function HandleRequest(Request As WebRequest, Response As WebResponse) As Boolean
		  // look for requests to get the latest token
		  
		  Dim path As String = Request.Path
		  Select Case path.LastField("/")
		  Case "token"
		    Dim newToken As String = GenerateNewToken
		    If newToken = "" Then
		      raise new UnsupportedOperationException("Could not generate a new mapkit token. Make sure your p8 certificate is in the correct folder.")
		    End If
		    Response.Write newToken
		    response.Status = 200
		    Return True
		  End Select
		End Function
	#tag EndEvent

	#tag Event
		Function JavaScriptClassName() As String
		  return "SOS.SOSMapKit"
		End Function
	#tag EndEvent

	#tag Event
		Sub Opening()
		  Dim js As String = "XojoWeb.getNamedControl('" + Self.ControlID + "').initializeMap('" + GenerateNewtoken + "', '" + session.LanguageCode + "');"
		  ExecuteJavaScript(js)
		End Sub
	#tag EndEvent

	#tag Event
		Sub Serialize(js as JSONItem)
		  Dim visibilities() As String = Array("adaptive", "hidden", "visible")
		  
		  // Constraints
		  js.Value("minimumZoomRange") = mMinimumZoomRange
		  js.Value("maximumZoomRange") = mMaximumZoomRange
		  
		  // Tools
		  js.Value("showsCompass") = visibilities(CType(mShowsCompass, Integer))
		  js.Value("showsMapTypeControl") = mShowsMapTypeControl
		  js.Value("showsPointsOfInterest") = mShowsPointsOfInterest
		  js.Value("showsScale") = visibilities(CType(mShowsScale, Integer))
		  js.Value("showsZoomControl") = mShowsZoomControl
		  
		  // Options
		  js.Value("scrollEnabled") = mScrollEnabled
		  
		  // Showing & Tracking user location
		  js.Value("showsUserLocationControl") = mShowsUserLocationControl
		  js.Value("showsUserLocation") = mShowsUserLocation
		  js.Value("tracksUserLocation") = mTracksUserLocation
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionCSSURLs(session as WebSession) As String()
		  
		End Function
	#tag EndEvent

	#tag Event
		Function SessionHead(session as WebSession) As String
		  
		  // Get the host from the session's header
		  Dim h As String = If(session.Secure, "https://", "http://") + session.Header("Host")
		  
		  // allow the developer to change it if necessary
		  SetWebsite(h)
		  
		  mHost = h
		  
		  Dim libraries() As String = SOSMaps.RequiredLibraries
		  
		  Return kHeaderLines.Replace("<<token>>", GenerateNewtoken).Replace("<<libraries>>", Join(libraries, ","))
		End Function
	#tag EndEvent

	#tag Event
		Function SessionJavascriptURLs(session as WebSession) As String()
		  // Since the library doesn't change per session, 
		  // we'll just make a shared property and serve
		  // the same file every time.
		  If mControlJS = Nil Then
		    mControlJS = New WebFile
		    mControlJS.Session = Nil
		    mControlJS.Data = kJavascriptControlCode
		    mControlJS.MIMEType = "text/javascript"
		    mControlJS.Filename = "sosmapkit.js"
		  End If
		  
		  Return Array(mControlJS.URL)
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddAnnotation(annotation as SOSMapKitAnnotation, focus as Boolean = False)
		  
		  MakeJSCall(param("ctl.addAnnotation(%1, %2, '%3', '%4', '%5', '%6', '%7', %8, %9)", annotation.Latitude.ToString, annotation.Longitude.ToString, ColorString(annotation.BackgroundColor), annotation.title, annotation.tag, annotation.subtitle, annotation.glyph, Str(annotation.selected).Lowercase, Str(focus).Lowercase))
		  mAnnotations.Add annotation
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ColorString(c as Color) As String
		  Dim parts() As String
		  parts.Add "#"
		  
		  parts.Add Right("0" + EncodeHex(Chr(c.Red)),2)
		  parts.Add Right("0" + EncodeHex(Chr(c.Green)),2)
		  parts.Add Right("0" + EncodeHex(Chr(c.Blue)),2)
		  
		  return join(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GenerateNewtoken() As String
		  Dim sh As New shell
		  
		  Dim appPath As String
		  
		  #If TargetMacOS
		    appPath = "dist/macOS/MapKitSigner"
		  #ElseIf TargetWindows
		    appPath = "dist/Windows/MapKitSigner.exe"
		  #ElseIf TargetLinux
		    appPath = "dist/Linux/MapKitSigner"
		  #Else
		    Return ""
		  #EndIf
		  
		  // Find the p8 file
		  Dim currentFolder As FolderItem = GetFolderItem("")
		  Dim currentPath As String = currentFolder.NativePath
		  Dim p8file As FolderItem
		  For Each file As FolderItem In currentFolder.Children
		    If file.Name.LastField(".") = "p8" Then
		      p8file = file
		      Exit For
		    End If
		  Next
		  
		  If p8file=Nil Then
		    p8file = LocateP8KeyFile
		  End If
		  
		  If p8file=Nil Then
		    Return ""
		  End If
		  
		  If SOSMapsConstants.kTokenKeyID = "Maps Key ID" Or SOSMapsConstants.kTokenTeamID = "Maps Team ID" Then
		    System.DebugLog "You must set the SOSMapsConstants.kTokenKeyID and SOSMapsConstants.kTokenTeamID constants!"
		    return ""
		  End If
		  
		  Dim cmd As String = Param("""%1"" %2 %3 ""%4"" ""%5"" %6", currentPath + "/" + appPath, SOSMapsConstants.kTokenKeyID, SOSMapsConstants.kTokenTeamID, p8file.nativepath, mHost, SOSMapsConstants.kTokenExpMinutes )
		  
		  sh.Execute cmd
		  
		  Return Trim(sh.Result)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MakeJSCall(cmd as string, paramarray values as Variant)
		  For i As Integer = UBound(values) DownTo 0
		    Dim value As String
		    Select Case values(i).Type
		    Case Variant.TypeString
		      value = """" + values(i).StringValue + """"
		    Case Variant.TypeBoolean
		      value = If(values(i).BooleanValue, "true", "false")
		    Case Else
		      value = values(i).StringValue
		    End Select
		    
		    Dim pat As String = "%" + Str(i+1)
		    cmd = cmd.ReplaceAll(pat, value)
		  Next
		  
		  Dim js() As String
		  
		  js.Add "var ctl = XojoWeb.controls.lookup('" + Self.ControlID + "');"
		  js.Add "if(ctl) {"
		  js.add cmd
		  js.Add "}"
		  
		  ExecuteJavaScript(Join(js, EndOfLine.Windows))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Param(pattern as string, paramarray replacements as string) As String
		  For i As Integer = UBound(replacements) DownTo 0
		    pattern = pattern.ReplaceAll("%" + Str(i+1), replacements(i))
		  Next
		  
		  return pattern
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveAnnotation(annotation as SOSMapKitAnnotation)
		  
		  
		  Dim p As Integer = mAnnotations.IndexOf(annotation)
		  If p > -1 Then
		    mAnnotations.RemoveAt(p)
		    
		    MakeJSCall(param("ctl.removeAnnotation('%1')", annotation.tag))
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetCameraDistance(meters as Double, animated as boolean = False)
		  MakeJSCall(Param("ctl.setCameraDistance(%1, %2)", meters.ToString, animated.ToString.Lowercase))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetCenter(latitude as Double, longitude as Double)
		  MakeJSCall(Param("ctl.setCenter(%1, %2)", latitude.ToString, longitude.ToString))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetRegion(latitude as Double, longitude as double, latitudeDelta as Double, longitudeDelta as Double)
		  MakeJSCall(Param("ctl.setRegion(%1, %2, %3, %4)", latitude.ToString, longitude.ToString, latitudeDelta.ToString, longitudeDelta.ToString))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateControl(sendImmediately as Boolean = False)
		  // Calling the overridden superclass method.
		  If mMapIsReady Then
		    Super.UpdateControl(sendImmediately)
		  End If
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Clicked(latitude as Double, longitude as Double)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Error(error as RuntimeException)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event LocateP8KeyFile() As Folderitem
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Opening()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Ready()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event SetWebsite(byref website as string)
	#tag EndHook


	#tag Property, Flags = &h21
		Private mAnnotations() As SOSMapKitAnnotation
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mMaximumZoomRange
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mMaximumZoomRange = value
			  UpdateControl
			  
			  // MakeJSCall("ctl.setProperty(""maximumZoomRange"", %1)", value)
			End Set
		#tag EndSetter
		MaximumZoomRange As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Shared mControlJS As WebFile
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHost As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mMinimumZoomRange
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mMinimumZoomRange = value
			  UpdateControl
			End Set
		#tag EndSetter
		MinimumZoomRange As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mMapIsReady As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMaximumZoomRange As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMinimumZoomRange As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollEnabled As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowsCompass As FeatureVisibility
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowsMapTypeControl As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowsPointsOfInterest As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowsScale As FeatureVisibility
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowsUserLocation As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowsUserLocationControl As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowsZoomControl As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTracksUserLocation As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mScrollEnabled
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mScrollEnabled = value
			  UpdateControl
			End Set
		#tag EndSetter
		ScrollEnabled As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mShowsCompass
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mShowsCompass = value
			  UpdateControl
			End Set
		#tag EndSetter
		ShowsCompass As FeatureVisibility
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mShowsMapTypeControl
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mShowsMapTypeControl = value
			  UpdateControl
			End Set
		#tag EndSetter
		ShowsMapTypeControl As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mShowsPointsOfInterest
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mShowsPointsOfInterest = value
			  UpdateControl
			End Set
		#tag EndSetter
		ShowsPointsOfInterest As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mShowsScale
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mShowsScale = value
			  UpdateControl
			End Set
		#tag EndSetter
		ShowsScale As FeatureVisibility
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mShowsUserLocation
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mShowsUserLocation = value
			  
			  UpdateControl
			End Set
		#tag EndSetter
		ShowsUserLocation As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mShowsUserLocationControl
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mShowsUserLocationControl = value
			  UpdateControl
			End Set
		#tag EndSetter
		ShowsUserLocationControl As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mShowsZoomControl
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mShowsZoomControl = value
			  UpdateControl
			End Set
		#tag EndSetter
		ShowsZoomControl As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTracksUserLocation
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTracksUserLocation = value
			  UpdateControl
			End Set
		#tag EndSetter
		TracksUserLocation As Boolean
	#tag EndComputedProperty


	#tag Constant, Name = kHeaderLines, Type = String, Dynamic = False, Default = \"<script\n  src\x3D\"https://cdn.apple-mapkit.com/mk/5.x.x/mapkit.core.js\"\n  crossorigin async\n  data-callback\x3D\"initMapKit\"\n  data-libraries\x3D\"<<libraries>>\"\n  data-initial-token\x3D\"<<token>>\"\n></script>", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kJavascriptControlCode, Type = String, Dynamic = False, Default = \"\"use strict\";\nvar SOS;\n(function (SOS) {\n    class SOSMapKit extends XojoWeb.XojoVisualControl {\n        constructor(id\x2C events) {\n            super(id\x2C events);\n            this.annotations \x3D new Map();\n            this.map \x3D null;\n            this.geocoder \x3D {};\n        }\n        updateControl(data) {\n            super.updateControl(data);\n            let js \x3D JSON.parse(data);\n            if (!this.map) {\n                return;\n            }\n            let mapkit \x3D SOS.SOSMapKit.mapkit;\n            this.map.showsUserLocation \x3D js.showsUserLocation;\n            this.map.tracksUserLocation \x3D js.tracksUserLocation;\n            this.map.showsCompass \x3D js.showsCompass;\n            this.map.showsMapTypeControl \x3D js.showsMapTypeControl;\n            this.map.showsPointsOfInterest \x3D js.showsPointsOfInterest;\n            this.map.showsScale \x3D js.showsScale;\n            this.map.showsUserLocationControl \x3D js.showsUserLocationControl;\n            this.map.showsZoomControl \x3D js.showsZoomControl;\n            this.map.isScrollEnabled \x3D js.scrollEnabled;\n            let min \x3D js.minimumZoomRange;\n            let max \x3D js.maximumZoomRange;\n            if (max <\x3D min) {\n                this.map.cameraZoomRange \x3D nil;\n            }\n            else {\n                let zoomRange \x3D new mapkit.CameraZoomRange(min\x2C max);\n                this.map.cameraZoomRange \x3D zoomRange;\n            }\n        }\n        close() {\n            this.map.destroy();\n        }\n        render() {\n            super.render();\n            let el \x3D this.DOMElement(\"\");\n            if (!el)\n                return;\n            this.setAttributes(null);\n            this.applyTooltip(el);\n            this.applyUserStyle(el);\n        }\n        async setupMapKitJs(token\x2C langcode) {\n            if (!window.mapkit || window.mapkit.loadedLibraries.length \x3D\x3D\x3D 0) {\n                await new Promise(resolve \x3D> { window.initMapKit \x3D resolve; });\n                delete window.initMapKit;\n            }\n            SOS.SOSMapKit.mapkit \x3D mapkit;\n            mapkit.init({\n                authorizationCallback: done \x3D> {\n                    const xhr \x3D new XMLHttpRequest();\n                    const url \x3D \"/sdk/\" + this.controlID(\"\") + \"/token\";\n                    xhr.open(\"GET\"\x2C url);\n                    xhr.onload \x3D function () {\n                        if (xhr.status \x3D\x3D\x3D 200) {\n                            done(xhr.responseText);\n                        }\n                        else {\n                            done(token);\n                        }\n                    };\n                    xhr.send();\n                }\x2C\n                language: langcode\n            });\n            let that \x3D this;\n            SOS.SOSMapKit.mapkit.addEventListener(\"error\"\x2C function (event) {\n                let data \x3D new XojoWeb.JSONItem;\n                data.set(\"message\"\x2C event.status);\n                that.triggerServerEvent(\'error\'\x2C data\x2C true);\n            });\n        }\n        async initializeMap(token\x2C langcode) {\n            var _a;\n            await this.setupMapKitJs(token\x2C langcode);\n            this.map \x3D new SOS.SOSMapKit.mapkit.Map(this.controlID(\"\"));\n            this.geocoder \x3D new SOS.SOSMapKit.mapkit.Geocoder({ language: langcode });\n            this.triggerServerEvent(\'ready\'\x2C null\x2C false);\n            if (this.implementsEvent(\"clicked\")) {\n                (_a \x3D this.map) \x3D\x3D\x3D null || _a \x3D\x3D\x3D void 0 \? void 0 : _a.addEventListener(\"single-tap\"\x2C event \x3D> {\n                    var _a;\n                    const point \x3D event.pointOnPage;\n                    const coordinate \x3D (_a \x3D this.map) \x3D\x3D\x3D null || _a \x3D\x3D\x3D void 0 \? void 0 : _a.convertPointOnPageToCoordinate(point);\n                    let data \x3D new XojoWeb.JSONItem;\n                    data.set(\"latitude\"\x2C coordinate.latitude);\n                    data.set(\"longitude\"\x2C coordinate.longitude);\n                    this.triggerServerEvent(\"clicked\"\x2C data\x2C false);\n                });\n            }\n        }\n        addAnnotation(latitude\x2C longitude\x2C color\x2C title\x2C tag\x2C subtitle \x3D \"\"\x2C glyph \x3D \"\"\x2C selected \x3D true\x2C show \x3D true) {\n            const place \x3D new SOS.SOSMapKit.mapkit.Coordinate(latitude\x2C longitude);\n            const annot \x3D new SOS.SOSMapKit.mapkit.MarkerAnnotation(place);\n            annot.color \x3D color;\n            annot.title \x3D title;\n            (subtitle !\x3D \"\") \? annot.subtitle \x3D subtitle : null;\n            annot.selected \x3D selected;\n            (glyph !\x3D \"\") \? annot.glyphText \x3D glyph : null;\n            if (show) {\n                this.map.showItems([annot]);\n            }\n            this.annotations.set(tag\x2C annot);\n        }\n        removeAnnotation(tag) {\n            let annot \x3D this.annotations.get(tag);\n            if (annot) {\n                this.map.removeAnnotation(annot);\n            }\n        }\n        setRegion(latitude\x2C longitude\x2C latitudeDelta\x2C longitudeDelta) {\n            let mapkit \x3D SOS.SOSMapKit.mapkit;\n            const region \x3D new mapkit.CoordinateRegion(new mapkit.Coordinate(latitude\x2C longitude)\x2C new mapkit.CoordinateSpan(latitudeDelta\x2C longitudeDelta));\n            this.map.region \x3D region;\n        }\n        setBounds(northLatitude\x2C eastLongitude\x2C southLatitude\x2C westLongitude) {\n            let mapkit \x3D SOS.SOSMapKit.mapkit;\n            const bounds \x3D new mapkit.BoundingRegion(northLatitude\x2C eastLongitude\x2C southLatitude\x2C westLongitude);\n            this.map.region \x3D bounds.toCoordinateRegion();\n        }\n        setCenter(latitude\x2C longitude) {\n            let mapkit \x3D SOS.SOSMapKit.mapkit;\n            this.map.center \x3D new mapkit.Coordinate(latitude\x2C longitude);\n        }\n        setCameraDistance(meters\x2C animated) {\n            if (animated) {\n                this.map.setCameraDistanceAnimated(meters);\n            }\n            else {\n                this.map.cameraDistance \x3D meters;\n            }\n        }\n        setPointOfInterestCategories(categories) {\n        }\n        setProperty(name\x2C value) {\n            this.map[name] \x3D value;\n        }\n    }\n    SOS.SOSMapKit \x3D SOSMapKit;\n})(SOS || (SOS \x3D {}));\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMapsOverlay, Type = String, Dynamic = False, Default = \"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\x3D\x3D", Scope = Private
	#tag EndConstant


	#tag Enum, Name = FeatureVisibility, Type = Integer, Flags = &h0
		Adaptive
		  Hidden
		Visible
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="200"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="300"
			Type="Integer"
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
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
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
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Visual Controls"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimumZoomRange"
			Visible=true
			Group="MapKit"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaximumZoomRange"
			Visible=true
			Group="MapKit"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScrollEnabled"
			Visible=true
			Group="MapKit"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowsCompass"
			Visible=true
			Group="MapKit"
			InitialValue="0"
			Type="FeatureVisibility"
			EditorType="Enum"
			#tag EnumValues
				"0 - Adaptive"
				"1 - Hidden"
				"2 - Visible"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowsMapTypeControl"
			Visible=true
			Group="MapKit"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowsPointsOfInterest"
			Visible=true
			Group="MapKit"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowsScale"
			Visible=true
			Group="MapKit"
			InitialValue="1"
			Type="FeatureVisibility"
			EditorType="Enum"
			#tag EnumValues
				"0 - Adaptive"
				"1 - Hidden"
				"2 - Visible"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowsUserLocation"
			Visible=true
			Group="MapKit"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowsUserLocationControl"
			Visible=true
			Group="MapKit"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowsZoomControl"
			Visible=true
			Group="MapKit"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TracksUserLocation"
			Visible=true
			Group="MapKit"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Indicator"
			Visible=false
			Group="Visual Controls"
			InitialValue="WebUIControl.Indicators.Default"
			Type="WebUIControl.Indicators"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Primary"
				"2 - Secondary"
				"3 - Success"
				"4 - Danger"
				"5 - Warning"
				"6 - Info"
				"7 - Light"
				"8 - Dark"
				"9 - Link"
			#tag EndEnumValues
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
