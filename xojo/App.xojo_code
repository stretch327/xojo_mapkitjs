#tag Class
Protected Class App
Inherits WebApplication
	#tag Event
		Sub Opening(args() as String)
		  SOSMaps.EnableAnnotations = True
		  SOSMaps.EnableServices = True 
		  SOSMaps.EnableGeoJSON = True 
		  
		  SOSMaps.EnableFullMap = False
		  SOSMaps.EnableOverlays = False // For drawing circles, rectangles and polylines on the map
		  SOSMaps.EnableUserLocation = False // For tracking and showing user location on the map
		End Sub
	#tag EndEvent


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
