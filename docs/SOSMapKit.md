# SOSMapKit Class

## Methods
**AddAnnotation(annotation as SOSMapKitAnnotation, focus as Boolean = False)**
Adds an Annotation(pin) to the map

**RemoveAnnotation(annotation as SOSMapKitAnnotation)**
Removes an Annotation from the map

**SetCameraDistance(meters as Double, animated as boolean = False)**
Sets the Camera distance

**SetCenter(latitude as Double, longitude as Double)**
Sets the map Center

**SetRegion(latitude as Double, longitude as double, latitudeDelta as Double, longitudeDelta as Double)**
Sets the visible region

## Properties
**MaximumZoomRange As Integer**
Sets the maximum zoom range. To disable, set maximum <= minimum.

**MinimumZoomRange As Integer**
Sets the minimum zoom range.

**ScrollEnabled As Boolean**
Enables map scrolling

**ShowsCompass As FeatureVisibility**
Shows the compass control.

**ShowsMapTypeControl As Boolean**
Shows the map type control.

**ShowsPointsOfInterest As Boolean**
Shows points of interest on the map

**ShowsScale As FeatureVisibility**
Shows the scale control.

**ShowsUserLocation As Boolean**
Shows the user location on the map.

**ShowsUserLocationControl As Boolean**
Shows the user location control.

**ShowsZoomControl As Boolean**
Shows the Zoom control.

**TracksUserLocation As Boolean**
Makes the map track the user's location.

## Enums
**Enumeration FeatureVisibility**
For ShowsCompass and ShowsScale properties. Allows the controls to be visible, hidden or adaptive depending on the state of the map.
Adaptive = 0
Hidden = 1
Visible = 2

