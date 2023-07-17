"use strict";
var SOS;
(function (SOS) {
    class SOSMapKit extends XojoWeb.XojoVisualControl {
        constructor(id, events) {
            super(id, events);
            this.annotations = new Map();
            this.map = null;
            this.geocoder = {};
        }
        updateControl(data) {
            super.updateControl(data);
            let js = JSON.parse(data);
            if (!this.map) {
                return;
            }
            let mapkit = SOS.SOSMapKit.mapkit;
            this.map.showsUserLocation = js.showsUserLocation;
            this.map.tracksUserLocation = js.tracksUserLocation;
            this.map.showsCompass = js.showsCompass;
            this.map.showsMapTypeControl = js.showsMapTypeControl;
            this.map.showsPointsOfInterest = js.showsPointsOfInterest;
            this.map.showsScale = js.showsScale;
            this.map.showsUserLocationControl = js.showsUserLocationControl;
            this.map.showsZoomControl = js.showsZoomControl;
            this.map.isScrollEnabled = js.scrollEnabled;
            let min = js.minimumZoomRange;
            let max = js.maximumZoomRange;
            if (max <= min) {
                this.map.cameraZoomRange = nil;
            }
            else {
                let zoomRange = new mapkit.CameraZoomRange(min, max);
                this.map.cameraZoomRange = zoomRange;
            }
        }
        close() {
            this.map.destroy();
        }
        render() {
            super.render();
            let el = this.DOMElement("");
            if (!el)
                return;
            this.setAttributes(null);
            this.applyTooltip(el);
            this.applyUserStyle(el);
        }
        async setupMapKitJs(token, langcode) {
            if (!window.mapkit || window.mapkit.loadedLibraries.length === 0) {
                await new Promise(resolve => { window.initMapKit = resolve; });
                delete window.initMapKit;
            }
            SOS.SOSMapKit.mapkit = mapkit;
            mapkit.init({
                authorizationCallback: done => {
                    const xhr = new XMLHttpRequest();
                    const url = "/sdk/" + this.controlID("") + "/token";
                    xhr.open("GET", url);
                    xhr.onload = function () {
                        if (xhr.status === 200) {
                            done(xhr.responseText);
                        }
                        else {
                            done(token);
                        }
                    };
                    xhr.send();
                },
                language: langcode
            });
            let that = this;
            SOS.SOSMapKit.mapkit.addEventListener("error", function (event) {
                let data = new XojoWeb.JSONItem;
                data.set("message", event.status);
                that.triggerServerEvent('error', data, true);
            });
        }
        async initializeMap(token, langcode) {
            var _a;
            await this.setupMapKitJs(token, langcode);
            this.map = new SOS.SOSMapKit.mapkit.Map(this.controlID(""));
            this.geocoder = new SOS.SOSMapKit.mapkit.Geocoder({ language: langcode });
            this.triggerServerEvent('ready', null, false);
            if (this.implementsEvent("clicked")) {
                (_a = this.map) === null || _a === void 0 ? void 0 : _a.addEventListener("single-tap", event => {
                    var _a;
                    const point = event.pointOnPage;
                    const coordinate = (_a = this.map) === null || _a === void 0 ? void 0 : _a.convertPointOnPageToCoordinate(point);
                    let data = new XojoWeb.JSONItem;
                    data.set("latitude", coordinate.latitude);
                    data.set("longitude", coordinate.longitude);
                    this.triggerServerEvent("clicked", data, false);
                });
            }
        }
        addAnnotation(latitude, longitude, color, title, tag, subtitle = "", glyph = "", selected = true, show = true) {
            const place = new SOS.SOSMapKit.mapkit.Coordinate(latitude, longitude);
            const annot = new SOS.SOSMapKit.mapkit.MarkerAnnotation(place);
            annot.color = color;
            annot.title = title;
            (subtitle != "") ? annot.subtitle = subtitle : null;
            annot.selected = selected;
            (glyph != "") ? annot.glyphText = glyph : null;
            if (show) {
                this.map.showItems([annot]);
            }
            this.annotations.set(tag, annot);
        }
        removeAnnotation(tag) {
            let annot = this.annotations.get(tag);
            if (annot) {
                this.map.removeAnnotation(annot);
            }
        }
        setRegion(latitude, longitude, latitudeDelta, longitudeDelta) {
            let mapkit = SOS.SOSMapKit.mapkit;
            const region = new mapkit.CoordinateRegion(new mapkit.Coordinate(latitude, longitude), new mapkit.CoordinateSpan(latitudeDelta, longitudeDelta));
            this.map.region = region;
        }
        setBounds(northLatitude, eastLongitude, southLatitude, westLongitude) {
            let mapkit = SOS.SOSMapKit.mapkit;
            const bounds = new mapkit.BoundingRegion(northLatitude, eastLongitude, southLatitude, westLongitude);
            this.map.region = bounds.toCoordinateRegion();
        }
        setCenter(latitude, longitude) {
            let mapkit = SOS.SOSMapKit.mapkit;
            this.map.center = new mapkit.Coordinate(latitude, longitude);
        }
        setCameraDistance(meters, animated) {
            if (animated) {
                this.map.setCameraDistanceAnimated(meters);
            }
            else {
                this.map.cameraDistance = meters;
            }
        }
        setPointOfInterestCategories(categories) {
        }
        setProperty(name, value) {
            this.map[name] = value;
        }
    }
    SOS.SOSMapKit = SOSMapKit;
})(SOS || (SOS = {}));
