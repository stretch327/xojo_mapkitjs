namespace SOS {
    export class SOSMapKit extends XojoWeb.XojoVisualControl {
        private annotations: Map<string, object>;
        public map: object | null;
        public geocoder: object;

        // Constructor for my controls
        constructor(id: string, events: string[]) {
            super(id, events);

            this.annotations = new Map<string, object>();
            this.map = null;
            this.geocoder = {}
        }

        public updateControl(data: string) {
            super.updateControl(data);
            let js = JSON.parse(data);

            if (!this.map) {
                return;
            }

            let mapkit = SOS.SOSMapKit.mapkit;

            // Tracking the user's location
            this.map.showsUserLocation = js.showsUserLocation;
            this.map.tracksUserLocation = js.tracksUserLocation;

            // shown controls
            this.map.showsCompass = js.showsCompass;
            this.map.showsMapTypeControl = js.showsMapTypeControl;
            this.map.showsPointsOfInterest = js.showsPointsOfInterest;
            this.map.showsScale = js.showsScale;
            this.map.showsUserLocationControl = js.showsUserLocationControl;
            this.map.showsZoomControl = js.showsZoomControl;

            this.map.isScrollEnabled = js.scrollEnabled;

            // Min/Max zoom range
            let min = js.minimumZoomRange;
            let max = js.maximumZoomRange;

            if (max <= min) {
                this.map.cameraZoomRange = nil;
            } else {
                let zoomRange = new mapkit.CameraZoomRange(min, max);
                this.map.cameraZoomRange = zoomRange
            }
        }

        public close() {
            this.map.destroy();
        }

        public render() {
            super.render();
            let el: HTMLElement | null = this.DOMElement("");

            if (!el) return;

            // Render here

            this.setAttributes(null);

            this.applyTooltip(el);

            this.applyUserStyle(el);
        }

        private async setupMapKitJs(token: string, langcode: string): Promise<void> {
            //@ts-ignore
            if (!window.mapkit || window.mapkit.loadedLibraries.length === 0) {
                //@ts-ignore
                await new Promise(resolve => { window.initMapKit = resolve });
                //@ts-ignore
                delete window.initMapKit;
                //@ts-ignore

            }

            //@ts-ignore
            SOS.SOSMapKit.mapkit = mapkit;

            //@ts-ignore
            mapkit.init({
                // @ts-ignore
                authorizationCallback: done => {
                    // send a request off the app to get the authorization
                    // latest token and then call the done method with the
                    // returned value

                    const xhr = new XMLHttpRequest();
                    const url = "/sdk/" + this.controlID("") + "/token"
                    xhr.open("GET", url);

                    xhr.onload = function () {
                        if (xhr.status === 200) {
                            done(xhr.responseText);
                        } else {
                            done(token);
                        }
                    }

                    xhr.send()
                },
                language: langcode
            });

            let that = this;
            SOS.SOSMapKit.mapkit.addEventListener("error", function (event: any) {
                let data = new XojoWeb.JSONItem;
                data.set("message", event.status);
                that.triggerServerEvent('error', data, true);
            })
        }

        public async initializeMap(token: string, langcode: string) {
            await this.setupMapKitJs(token, langcode);

            this.map = new SOS.SOSMapKit.mapkit.Map(this.controlID(""));
            this.geocoder = new SOS.SOSMapKit.mapkit.Geocoder({ language: langcode });

            this.triggerServerEvent('ready', null, false);

            if (this.implementsEvent("clicked")) {
                this.map?.addEventListener("single-tap", event => {
                    const point = event.pointOnPage;
                    const coordinate = this.map?.convertPointOnPageToCoordinate(point);

                    let data = new XojoWeb.JSONItem
                    data.set("latitude", coordinate.latitude);
                    data.set("longitude", coordinate.longitude);
                    this.triggerServerEvent("clicked", data, false)
                })
            }
        }

        public addAnnotation(latitude: number, longitude: number, color: string, title: string, tag: string, subtitle: string = "", glyph: string = "", selected: boolean = true, show: boolean = true) {
            const place = new SOS.SOSMapKit.mapkit.Coordinate(latitude, longitude);
            const annot = new SOS.SOSMapKit.mapkit.MarkerAnnotation(place);
            annot.color = color;
            annot.title = title;
            (subtitle != "") ? annot.subtitle = subtitle : null;
            annot.selected = selected;
            (glyph != "") ? annot.glyphText = glyph : null;

            if (show) {
                // @ts-ignore
                this.map.showItems([annot]);
            }

            this.annotations.set(tag, annot);
        }

        public removeAnnotation(tag: string) {
            let annot = this.annotations.get(tag);
            if (annot) {
                //@ts-ignore
                this.map.removeAnnotation(annot);
            }
        }

        public setRegion(latitude: number, longitude: number, latitudeDelta: number, longitudeDelta: number) {
            let mapkit = SOS.SOSMapKit.mapkit;
            const region = new mapkit.CoordinateRegion(
                new mapkit.Coordinate(latitude, longitude),
                new mapkit.CoordinateSpan(latitudeDelta, longitudeDelta)
            )
            //@ts-ignore
            this.map.region = region;
        }

        public setBounds(northLatitude: number, eastLongitude: number, southLatitude: number, westLongitude: number) {
            let mapkit = SOS.SOSMapKit.mapkit;
            const bounds = new mapkit.BoundingRegion(
                northLatitude,
                eastLongitude,
                southLatitude,
                westLongitude
            )

            //@ts-ignore
            this.map.region = bounds.toCoordinateRegion();
        }

        public setCenter(latitude: number, longitude: number) {
            let mapkit = SOS.SOSMapKit.mapkit;
            this.map.center = new mapkit.Coordinate(latitude, longitude);
        }

        public setCameraDistance(meters: number, animated: boolean) {
            if (animated) {
                this.map.setCameraDistanceAnimated(meters);
            } else {
                this.map.cameraDistance = meters;
            }
        }

        public setPointOfInterestCategories(categories: [string]) {

        }

        public setProperty(name: string, value: any) {
            this.map[name] = value;
        }

        // @ts-ignore
        static mapkit;
    }
}