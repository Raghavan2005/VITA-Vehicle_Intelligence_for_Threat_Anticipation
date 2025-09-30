import QtQuick 2.15
import QtLocation 5.9
import QtQuick.Controls 2.5
import Qt5Compat.GraphicalEffects 1.0
import QtPositioning 5.15

Page {
    id: pageMap

    property var currentLoc: QtPositioning.coordinate(13.0843, 80.2705)
    property var destinationLoc: QtPositioning.coordinate()
    property bool isRoutingStart: false
    property bool enableGradient: true
    property var lastClickedCoordinate: null

    function adaptiveWidth(n) { return n; }
    function adaptiveHeight(n) { return n; }

    // Nominatim Geocoding (async)
    function geocode(query, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var results = JSON.parse(xhr.responseText);
                    if (results.length > 0) {
                        var coord = QtPositioning.coordinate(Number(results[0].lat), Number(results[0].lon));
                        callback(coord);
                    } else {
                        callback(null);
                    }
                } else {
                    callback(null);
                }
            }
        }
        var url = "https://nominatim.openstreetmap.org/search?format=json&q=" + encodeURIComponent(query);
        xhr.open("GET", url);
        xhr.send();
    }

    // Reverse geocoding - get address from coordinates
    function reverseGeocode(coord, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var result = JSON.parse(xhr.responseText);
                    if (result.display_name) {
                        callback(result.display_name);
                    } else {
                        callback("Unknown location");
                    }
                } else {
                    callback("Geocoding failed");
                }
            }
        }
        var url = "https://nominatim.openstreetmap.org/reverse?format=json&lat=" + coord.latitude + "&lon=" + coord.longitude;
        xhr.open("GET", url);
        xhr.send();
    }

    // Start route to coordinate
    function startRouteToCoordinate(coord) {
        destinationLoc = coord;
        routeQuery.clearWaypoints();
        routeQuery.addWaypoint(currentLoc);
        routeQuery.addWaypoint(destinationLoc);
        routeModel.update();
        destinationMarker.visible = true;
    }

    // Start route to address
    function startRouteTo(address) {
        geocode(address, function(coord) {
            if (coord !== null) {
                startRouteToCoordinate(coord);
            } else {
                console.log("Geocode failed");
            }
        });
    }

    // Clear route and markers
    function clearRoute() {
        routeModel.reset();
        destinationMarker.visible = false;
        startMarker.visible = false;
        currentLocationMarker.visible = false;
        clickMarker.visible = false;
        isRoutingStart = false;
        simulateDrive.running = false;
    }

    // Set new current location
    function setCurrentLocation(coord) {
        currentLoc = coord;
        currentLocationMarker.coordinate = coord;
        map.center = coord;
    }

    RadialGradient {
        z: 1
        visible: enableGradient
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.72; color: "#000000" }
        }
    }

    Plugin {
        id: osmPlugin
        name: "osm"
        PluginParameter {
            name: "osm.mapping.highdpi_tiles"
            value: true
        }
    }

    Map {
        id: map
        anchors.fill: parent
        center: currentLoc
        zoomLevel: 13.3
        bearing: 0
        plugin: osmPlugin

        // Map gestures are enabled by default - no need for gesture property

        // Mouse area for map clicks
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: function(mouse) {
                var coord = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                lastClickedCoordinate = coord;

                if (mouse.button === Qt.LeftButton) {
                    // Left click - show marker and info
                    clickMarker.coordinate = coord;
                    clickMarker.visible = true;

                    // Show coordinates in info panel
                    coordInfoText.text = "Lat: " + coord.latitude.toFixed(6) + "\nLon: " + coord.longitude.toFixed(6);

                    // Get address for clicked location
                    reverseGeocode(coord, function(address) {
                        coordInfoText.text += "\n\n" + address;
                    });

                } else if (mouse.button === Qt.RightButton) {
                    // Right click - set as destination
                    startRouteToCoordinate(coord);
                }
            }

            onDoubleClicked: function(mouse) {
                var coord = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                // Zoom in on double click
                map.zoomLevel += 1;
                map.center = coord;
            }

            onWheel: function(wheel) {
                // Zoom with mouse wheel
                if (wheel.angleDelta.y > 0) {
                    map.zoomLevel += 0.5;
                } else {
                    map.zoomLevel -= 0.5;
                }
            }
        }

        // Map items for routes and markers
        MapItemView {
            id: mapRouteLine
            model: routeModel
            delegate: MapRoute {
                route: routeData
                line.color: "black"
                line.width: adaptiveWidth(7)
            }
        }

        // Current location marker (car)
        MapQuickItem {
            id: currentLocationMarker
            coordinate: currentLoc
            visible: true
            z: 2
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            sourceItem: Rectangle {
                width: adaptiveWidth(40)
                height: adaptiveHeight(40)
                color: "transparent"
                Image {
                    id: car
                    width: parent.width
                    height: parent.height
                    source: "qrc:/Map/CarMarker.png"
                    anchors.centerIn: parent
                }
            }
            Behavior on coordinate {
                PropertyAnimation { duration: 500 }
            }
        }

        // Destination marker
        MapQuickItem {
            id: destinationMarker
            coordinate: destinationLoc
            visible: false
            z: 2
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            sourceItem: Rectangle {
                width: adaptiveWidth(40)
                height: adaptiveHeight(40)
                color: "transparent"
                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "red"
                    radius: width/2
                    border.width: 3
                    border.color: "white"
                    Text {
                        text: "D"
                        color: "white"
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }
            }
        }

        // Click marker for user interactions
        MapQuickItem {
            id: clickMarker
            coordinate: currentLoc
            visible: false
            z: 3
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
            sourceItem: Rectangle {
                width: adaptiveWidth(30)
                height: adaptiveHeight(30)
                color: "blue"
                radius: width/2
                border.width: 2
                border.color: "white"

                Rectangle {
                    width: adaptiveWidth(15)
                    height: adaptiveHeight(15)
                    color: "white"
                    radius: width/2
                    anchors.centerIn: parent
                }
            }
        }

        RouteModel {
            id: routeModel
            plugin: osmPlugin
            query: RouteQuery {
                id: routeQuery
                travelModes: RouteQuery.CarTravel
            }
            onRoutesChanged: {
                if (routeModel.count > 0) {
                    const path = routeModel.get(0).path
                    map.center = path[Math.floor(path.length / 2)]
                    destinationMarker.visible = true
                    startMarker.visible = true
                    animationTimer.running = true
                }
            }
            onStatusChanged: {
                if (status === RouteModel.Error) {
                    console.log("Route calculation error: " + errorString)
                }
            }
        }

        Timer {
            id: animationTimer
            interval: 2000
            repeat: false
            onTriggered: {
                startMarker.visible = false
                currentLocationMarker.visible = true
                isRoutingStart = true
                simulateDrive.index = 0
                simulateDrive.path = routeModel.get(0).path
                simulateDrive.running = true
            }
        }

        Timer {
            id: simulateDrive
            property var path: []
            property int index: 0
            interval: 1000
            repeat: true
            running: false
            onTriggered: {
                if (path && path.length > index) {
                    currentLocationMarker.coordinate = path[index]
                    index++
                } else {
                    running = false
                    isRoutingStart = false
                    console.log("Route simulation completed")
                }
            }
        }
    }

    // Control Panel
    Rectangle {
        id: controlPanel
        width: adaptiveWidth(300)
        height: adaptiveHeight(200)
        color: "#e0e0e0"
        radius: 10
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        opacity: 0.9

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Text {
                text: "Map Controls"
                font.bold: true
                font.pixelSize: adaptiveHeight(16)
            }

            Button {
                text: "Zoom In"
                width: parent.width
                onClicked: map.zoomLevel += 1
            }

            Button {
                text: "Zoom Out"
                width: parent.width
                onClicked: map.zoomLevel -= 1
            }

            Button {
                text: "Reset View"
                width: parent.width
                onClicked: {
                    map.center = currentLoc
                    map.zoomLevel = 13.3
                    map.bearing = 0
                }
            }

            Button {
                text: "Clear Route"
                width: parent.width
                onClicked: clearRoute()
            }
        }
    }

    // Coordinate Info Panel
    Rectangle {
        id: coordInfoPanel
        width: adaptiveWidth(250)
        height: adaptiveHeight(120)
        color: "#e0e0e0"
        radius: 10
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10
        opacity: 0.9
        visible: clickMarker.visible

        Text {
            id: coordInfoText
            anchors.fill: parent
            anchors.margins: 10
            font.pixelSize: adaptiveHeight(12)
            wrapMode: Text.Wrap
            text: "Click on map to see coordinates"
        }
    }

    // Search Box
    Rectangle {
        id: searchBox
        width: adaptiveWidth(300)
        height: adaptiveHeight(50)
        color: "white"
        radius: 25
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        opacity: 0.9

        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: adaptiveHeight(14)
         //   placeholderText: "Search location..."

            onAccepted: {
                if (text.length > 0) {
                    startRouteTo(text);
                    searchInput.text = "";
                }
            }
        }
    }

    // Navigation Instructions
    Rectangle {
        id: instructionPanel
        width: parent.width - 20
        height: adaptiveHeight(60)
        color: "#e0e0e0"
        radius: 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        opacity: 0.9

        Text {
            anchors.centerIn: parent
            font.pixelSize: adaptiveHeight(12)
            text: "• Left Click: Show coordinates • Right Click: Set destination • Double Click: Zoom in • Mouse Wheel: Zoom • Drag: Pan"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
