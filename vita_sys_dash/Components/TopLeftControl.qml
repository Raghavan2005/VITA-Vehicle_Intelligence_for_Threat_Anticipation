import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0

RowLayout {
    id: root
    property int index: 0
    property int batteryPercentage: 90
    spacing: 51

    // Mock data timer
    Timer {
        id: mockDataTimer
        interval: 3000 // Update every 3 seconds
        running: true
        repeat: true
        onTriggered: updateMockData()
    }

    // Function to generate random mock data
    function updateMockData() {
        // Random gear change (0=P, 1=R, 2=N, 3=D)
        var newGear = Math.floor(Math.random() * 4);
        if (newGear !== root.index) {
            root.index = newGear;
            gearChanged(newGear);
        }

        // Random battery percentage (between 10% and 100%)
        var newBattery = Math.floor(Math.random() * 91) + 10;
        if (newBattery !== root.batteryPercentage) {
            root.batteryPercentage = newBattery;
            batteryLevelChanged(newBattery);
        }
    }

    // Function to manually set gear
    function setGear(gearIndex) {
        if (gearIndex >= 0 && gearIndex <= 3) {
            root.index = gearIndex;
            gearChanged(gearIndex);
        }
    }

    // Function to manually set battery percentage
    function setBattery(percentage) {
        if (percentage >= 0 && percentage <= 100) {
            root.batteryPercentage = percentage;
            batteryLevelChanged(percentage);
        }
    }

    // Gear indicators with click functionality
    RowLayout {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        spacing: 4

        // P - Park
        MouseArea {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            cursorShape: Qt.PointingHandCursor

            onClicked: root.setGear(0)

            Text {
                anchors.centerIn: parent
                property bool current: root.index === 0
                color: current ? (Style.isDark ? Style.white : "#171717") : Style.black20
                text: "P"
                font.family: "Inter"
                font.bold: Font.Bold
                font.pixelSize: 18

                // Scale animation when active
                scale: current ? 1.2 : 1.0
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }

        // R - Reverse
        MouseArea {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            cursorShape: Qt.PointingHandCursor

            onClicked: root.setGear(1)

            Text {
                anchors.centerIn: parent
                property bool current: root.index === 1
                color: current ? (Style.isDark ? Style.white : "#171717") : Style.black20
                text: "R"
                font.family: "Inter"
                font.bold: Font.Bold
                font.pixelSize: 18

                scale: current ? 1.2 : 1.0
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }

        // N - Neutral
        MouseArea {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            cursorShape: Qt.PointingHandCursor

            onClicked: root.setGear(2)

            Text {
                anchors.centerIn: parent
                property bool current: root.index === 2
                color: current ? (Style.isDark ? Style.white : "#171717") : Style.black20
                text: "N"
                font.family: "Inter"
                font.bold: Font.Bold
                font.pixelSize: 18

                scale: current ? 1.2 : 1.0
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }

        // D - Drive
        MouseArea {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            cursorShape: Qt.PointingHandCursor

            onClicked: root.setGear(3)

            Text {
                anchors.centerIn: parent
                property bool current: root.index === 3
                color: current ? (Style.isDark ? Style.white : "#171717") : Style.black20
                text: "D"
                font.family: "Inter"
                font.bold: Font.Bold
                font.pixelSize: 18

                scale: current ? 1.2 : 1.0
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }
    }

    // Battery indicator with click functionality
    MouseArea {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        implicitWidth: batteryLayout.implicitWidth
        implicitHeight: batteryLayout.implicitHeight
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            // Toggle between showing percentage and hiding it
            batteryText.visible = !batteryText.visible;
        }

        RowLayout {
            id: batteryLayout
            spacing: 8

            // Battery icon with dynamic color based on level
            Rectangle {
                id: batteryIconContainer
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                width: 24
                height: 12
                color: "transparent"
                border.color: getBatteryColor()
                border.width: 1
                radius: 1

                // Battery tip
                Rectangle {
                    x: parent.width
                    y: parent.height / 4
                    width: 2
                    height: parent.height / 2
                    color: getBatteryColor()
                }

                // Battery level fill
                Rectangle {
                    id: batteryLevelFill
                    x: 1
                    y: 1
                    width: (parent.width - 2) * (root.batteryPercentage / 100)
                    height: parent.height - 2
                    color: getBatteryColor()
                    radius: 1

                    Behavior on width {
                        NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                    }
                }

                function getBatteryColor() {
                    if (root.batteryPercentage > 70) return "#4CAF50"; // Green
                    if (root.batteryPercentage > 30) return "#FF9800"; // Orange
                    return "#F44336"; // Red
                }
            }

            Text {
                id: batteryText
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Style.isDark ? Style.white : Style.black10
                text: qsTr("%0%").arg(batteryPercentage)
                font.family: "Inter"
                font.bold: Font.Bold
                font.pixelSize: 18

                // Blink animation when battery is low
                opacity: (root.batteryPercentage <= 15 && Math.floor(Date.now() / 500) % 2 === 0) ? 0.3 : 1.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    // Signals
    signal gearChanged(int newGear)
    signal batteryLevelChanged(int newPercentage)
    signal batteryClicked()

    // Initial mock data setup
    Component.onCompleted: {
        console.log("Gear indicator component loaded");
        updateMockData();
    }

    // Debug information (optional)
    onGearChanged: {
        var gearNames = ["Park", "Reverse", "Neutral", "Drive"];
        console.log("Gear changed to:", gearNames[newGear]);
    }

    onBatteryLevelChanged: {
        console.log("Battery level changed to:", newPercentage + "%");
    }
}
