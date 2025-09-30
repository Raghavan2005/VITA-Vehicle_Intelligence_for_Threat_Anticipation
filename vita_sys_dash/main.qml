import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0
import Qt5Compat.GraphicalEffects
import "Components"
import "qrc:/LayoutManager.js" as Responsive

ApplicationWindow {
    id: root
    width: 1280
    height: 720
    maximumHeight: height
    minimumHeight: height
    maximumWidth: width
    minimumWidth: width
    visible: true
    title: qsTr("TATA VITA")
    onWidthChanged: {
        if(adaptive)
            adaptive.updateWindowWidth(root.width)
    }

    onHeightChanged: {
        if(adaptive)
            adaptive.updateWindowHeight(root.height)
    }
    property var adaptive: new Responsive.AdaptiveLayoutManager(root.width,root.height, root.width,root.height)

    FontLoader {
        id: uniTextFont
        source: "qrc:/Fonts/Unitext Regular.ttf"
    }

    background: Loader {
        anchors.fill: parent
        sourceComponent: Style.mapAreaVisible ? backgroundRect : backgroundImage
    }

    Header {
        z: 99
        id: headerLayout
    }

    footer: Footer{
        id: footerLayout
        onOpenLauncher: launcher.open()
    }

    TopLeftButtonIconColumn {
        z: 99
        anchors.left: parent.left
        anchors.top: headerLayout.bottom
        anchors.leftMargin: 18
    }

    RowLayout {
        id: mapLayout
        visible: Style.mapAreaVisible
        spacing: 0
        anchors.fill: parent
        Item {
            Layout.preferredWidth: 620
            Layout.fillHeight: true
            Image {
                anchors.centerIn: parent
                source: Style.isDark ? "qrc:/icons/light/sidebar.png" : "qrc:/icons/dark/sidebar-light.png"
            }
        }

        NavigationMapHelperScreen {
            Layout.fillWidth: true
            Layout.fillHeight: true
            runMenuAnimation: true
        }
    }
    Rectangle {
            id: centerNotification
            anchors.centerIn: parent
            width: 400
            height: 120
            radius: 20
            color: Style.isDark ? "#2A2A2A" : "#FFFFFF"
            opacity: 0
            scale: 0.8
            visible: opacity > 0
            z: 1000 // Ensure it's on top of everything

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 10
                radius: 20
                samples: 25
                color: "#80000000"
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "VITA"
                    font.family: "Inter"
                    font.bold: Font.Bold
                    font.pixelSize: 32
                    font.capitalization: Font.AllUppercase
                    color: "#4CAF50"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    id: statusText
                    text: "SYSTEM OFFLINE"
                    font.family: "Inter"
                    font.bold: Font.Medium
                    font.pixelSize: 18
                    font.capitalization: Font.AllUppercase
                    color: Style.isDark ? "#FFFFFF" : "#666666"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Close button
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                width: 30
                height: 30
                radius: 15
                color: "transparent"
                border.color: Style.isDark ? "#555555" : "#CCCCCC"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    font.pixelSize: 20
                    font.bold: true
                    color: Style.isDark ? "#FFFFFF" : "#666666"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: centerNotification.hide()
                }
            }

            function show(systemOnline) {
                statusText.text = systemOnline ? "SYSTEM ONLINE" : "SYSTEM OFFLINE";
                centerNotificationAnimation.start();
                autoHideTimer.start();
            }

            function hide() {
                centerNotificationHideAnimation.start();
                autoHideTimer.stop();
            }

            SequentialAnimation {
                id: centerNotificationAnimation
                ParallelAnimation {
                    NumberAnimation {
                        target: centerNotification
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 500
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: centerNotification
                        property: "scale"
                        from: 0.8
                        to: 1
                        duration: 500
                        easing.type: Easing.OutBack
                    }
                }
            }

            SequentialAnimation {
                id: centerNotificationHideAnimation
                ParallelAnimation {
                    NumberAnimation {
                        target: centerNotification
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: centerNotification
                        property: "scale"
                        from: 1
                        to: 0.8
                        duration: 300
                        easing.type: Easing.InCubic
                    }
                }
            }

            Timer {
                id: autoHideTimer
                interval: 3000
                onTriggered: centerNotification.hide()
            }
        }

        // Global function for header to call
        function showVitaNotification(systemOnline) {
            centerNotification.show(systemOnline);
        }
    LaunchPadControl {
        id: launcher
        y: (root.height - height) / 2 + (footerLayout.height)
        x: (root.width - width ) / 2
    }

    Component {
        id: backgroundRect
        Rectangle {
            color: "#171717"
            anchors.fill: parent
        }
    }

    Component {
        id: backgroundImage
        Image {
            source: Style.getImageBasedOnTheme()



        }
    }
    // Safety Systems Slider Panel
        Rectangle {
            id: safetySlider
            width: 450
            height: parent.height
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                rightMargin: -width // Start off-screen
            }
            color: Style.isDark ? "#1A1A1A" : "#FFFFFF"
            radius: 20
            opacity: 0
            visible: opacity > 0
            z: 1000

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: -5
                verticalOffset: 5
                radius: 25
                samples: 25
                color: "#80000000"
            }

            // Header
            Rectangle {
                id: sliderHeader
                width: parent.width
                height: 80
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20

                    Text {
                        text: "SAFETY SYSTEMS"
                        font.family: "Inter"
                        font.bold: Font.Bold
                        font.pixelSize: 22
                        font.capitalization: Font.AllUppercase
                        color: Style.isDark ? Style.white : Style.black20
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Close button
                    Rectangle {
                        id: closeButton
                        width: 36
                        height: 36
                        radius: 18
                        color: "transparent"
                        border.color: Style.isDark ? "#555555" : "#CCCCCC"
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            font.pixelSize: 20
                            font.bold: true
                            color: Style.isDark ? "#FFFFFF" : "#666666"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: safetySlider.close()
                        }
                    }
                }

                // Separator
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Style.isDark ? Style.alphaColor(Style.white, 0.1) : Style.alphaColor(Style.black, 0.1)
                }
            }

            // Safety Systems Content
            Flickable {
                id: safetyFlickable
                anchors {
                    top: sliderHeader.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 20
                }
                contentWidth: width
                contentHeight: safetyColumn.height
                clip: true

                ColumnLayout {
                    id: safetyColumn
                    width: parent.width - 10
                    spacing: 15

                    SafetySystemToggle {
                        systemName: "Curve Speed Assist"
                        systemDescription: "Monitors curve speed, takes steering control if overspeeding"
                        defaultValue: true
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Rear Collision Mitigation"
                        systemDescription: "Controls throttle and braking to avoid rear-end collisions"
                        defaultValue: true
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Emergency Steering Assist"
                        systemDescription: "Automatic steering intervention to avoid obstacles"
                        defaultValue: true
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Forward Collision Avoidance"
                        systemDescription: "Supports steering control to prevent frontal collisions"
                        defaultValue: true
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Road Surface Monitoring"
                        systemDescription: "Detects potholes/rough surfaces, adjusts suspension"
                        defaultValue: false
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Driver State Monitoring"
                        systemDescription: "Tracks drowsiness, distraction, and driver alertness"
                        defaultValue: true
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Automatic Emergency Call"
                        systemDescription: "Automatically contacts emergency services after accident"
                        defaultValue: true
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Emergency Vehicle Corridor"
                        systemDescription: "Predicts traffic flow for emergency vehicles"
                        defaultValue: false
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Driver State Prediction"
                        systemDescription: "Predicts when driver is likely to lose focus"
                        defaultValue: false
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Dynamic Risk Mapping"
                        systemDescription: "Learns risky zones and raises system sensitivity"
                        defaultValue: false
                        Layout.fillWidth: true
                    }

                    SafetySystemToggle {
                        systemName: "Automatic Collision Avoidance"
                        systemDescription: "Automatic slowdown and collision avoidance system"
                        defaultValue: true
                        Layout.fillWidth: true
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 8
                }
            }

            // Open/Close functions
            function open() {
                safetySliderAnimation.start();
                overlay.visible = true;
            }

            function close() {
                safetySliderCloseAnimation.start();
                overlay.visible = false;
            }

            // Open animation
            SequentialAnimation {
                id: safetySliderAnimation
                ParallelAnimation {
                    NumberAnimation {
                        target: safetySlider
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: safetySlider
                        property: "anchors.rightMargin"
                        from: -safetySlider.width
                        to: 0
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Close animation
            SequentialAnimation {
                id: safetySliderCloseAnimation
                ParallelAnimation {
                    NumberAnimation {
                        target: safetySlider
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 250
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: safetySlider
                        property: "anchors.rightMargin"
                        from: 0
                        to: -safetySlider.width
                        duration: 350
                        easing.type: Easing.InCubic
                    }
                }
            }
        }

        // Overlay to close when clicking outside
        Rectangle {
            id: overlay
            anchors.fill: parent
            color: "#20000000"
            opacity: safetySlider.opacity > 0 ? 1 : 0
            visible: false
            z: 999

            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: safetySlider.close()
            }
        }
}
