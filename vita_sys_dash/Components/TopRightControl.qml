import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0
import Qt5Compat.GraphicalEffects

RowLayout {
    id: headerRow
    spacing: 48

    property int temp: 72
    property bool airbagOn: false
    property bool tempControlEnabled: true
    property bool showSeconds: false

    // Timer to update time automatically
    Timer {
        id: timeUpdateTimer
        interval: showSeconds ? 1000 : 60000 // Update every second or minute
        running: true
        repeat: true
        onTriggered: updateTime()
    }

    function updateTime() {
        var format = showSeconds ? "h:mm:ss ap" : "h:mmap";
        timeText.text = Qt.formatDateTime(new Date(), format);
    }

    // Time display with click to show seconds
    MouseArea {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        implicitWidth: timeText.implicitWidth
        implicitHeight: timeText.implicitHeight
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            showSeconds = !showSeconds;
            updateTime();
            headerRow.timeClicked();
        }

        Text {
            id: timeText
            anchors.centerIn: parent
            text: Qt.formatDateTime(new Date(), "h:mmap")
            font.family: "Inter"
            font.pixelSize: 18
            font.bold: Font.DemiBold
            color: Style.isDark ? Style.white : Style.black20
        }
    }

    // Temperature display with click and hold functionality
    MouseArea {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        implicitWidth: tempText.implicitWidth + 20
        implicitHeight: tempText.implicitHeight + 10
        enabled: tempControlEnabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        pressAndHoldInterval: 500

        onClicked: toggleTemperatureUnit()
        onPressAndHold: tempPopup.open()

        Text {
            id: tempText
            anchors.centerIn: parent
            text: "%0ºF".arg(temp)
            font.family: "Inter"
            font.pixelSize: 18
            font.bold: Font.DemiBold
            color: Style.isDark ? Style.white : Style.black20
        }

        // Popup for temperature control
        Popup {
            id: tempPopup
            x: -width/2 + parent.width/2
            y: parent.height + 5
            width: 120
            height: 40

            background: Rectangle {
                color: Style.isDark ? Style.darkBackground : Style.white
                radius: 5
                border.color: Style.gray
            }

            contentItem: RowLayout {
                spacing: 5

                Button {
                    text: "-"
                    onClicked: headerRow.decreaseTemperature()
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: temp + "º"
                    font.bold: true
                }

                Button {
                    text: "+"
                    onClicked: headerRow.increaseTemperature()
                }
            }
        }
    }

    MouseArea {
        id: airbagToggle
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        implicitWidth: airbagControl.implicitWidth
        implicitHeight: airbagControl.implicitHeight
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            // Ripple animation
            rippleEffect.start();
            // Show center notification (will be handled by main application)
            if (typeof showVitaNotification !== "undefined") {
                showVitaNotification(!airbagOn);
            }
            // Toggle after a small delay for better UX
            toggleTimer.start();
        }

        Timer {
            id: toggleTimer
            interval: 150
            onTriggered: headerRow.toggleAirbag()
        }

        // Ripple effect
        Rectangle {
            id: rippleEffect
            property real size: 0
            property real opacityValue: 0.6

            anchors.centerIn: parent
            width: size
            height: size
            radius: width / 2
            color: airbagOn ? "#4CAF50" : "#E0E0E0"
            opacity: opacityValue
            visible: false

            function start() {
                size = 0;
                opacityValue = 0.6;
                visible = true;
                rippleAnimation.start();
            }

            SequentialAnimation {
                id: rippleAnimation
                ParallelAnimation {
                    NumberAnimation {
                        target: rippleEffect
                        property: "size"
                        from: 0
                        to: Math.max(airbagToggle.width, airbagToggle.height) * 1.5
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: rippleEffect
                        property: "opacityValue"
                        from: 0.6
                        to: 0
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
                ScriptAction {
                    script: rippleEffect.visible = false
                }
            }
        }

        Control {
            id: airbagControl
            implicitHeight: 42
            implicitWidth: 140

            background: Rectangle {
                id: bgRect
                color: getBackgroundColor()
                radius: 10
                border.width: 2
                border.color: getBorderColor()

                // Smooth shadow effect
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 8
                    samples: 17
                    color: airbagOn ? "#204CAF50" : "#20000000"
                }

                // Scale animation on click
                scale: airbagToggle.pressed ? 0.95 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: 400; easing.type: Easing.OutCubic } }

                function getBackgroundColor() {
                    if (airbagOn) {
                        return Style.isDark ? "#1B5E20" : "#E8F5E8";
                    } else {
                        return Style.isDark ? Style.alphaColor(Style.black, 0.7) : "#F5F5F5";
                    }
                }

                function getBorderColor() {
                    if (airbagOn) {
                        return Style.isDark ? "#4CAF50" : "#4CAF50";
                    } else {
                        return Style.isDark ? Style.alphaColor(Style.white, 0.2) : "#E0E0E0";
                    }
                }
            }

            contentItem: RowLayout {
                spacing: 12
                anchors.centerIn: parent

                // Animated icon container
                Rectangle {
                    id: iconContainer
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    Layout.leftMargin:  10

                    radius: 14
                    color: airbagOn ?
                           (Style.isDark ? "#4CAF50" : "#4CAF50") :
                           (Style.isDark ? Style.alphaColor(Style.white, 0.1) : "#E0E0E0")

                    Behavior on Layout.leftMargin {
                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                    }
                    Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.OutCubic } }

                    Image {
                        anchors.centerIn: parent
                        source: airbagOn ?
                               "qrc:/icons/top_header_icons/airbag_on.svg" :
                               "qrc:/icons/top_header_icons/airbag_off.svg"
                        sourceSize: Qt.size(16, 16)
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: airbagOn ? "white" : (Style.isDark ? "#B0B0B0" : "#666666")
                        }
                    }
                }

                // Text content
                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        id: vitaText
                        text: "VITA"
                        font.family: "Inter"
                        font.bold: Font.Bold
                        font.pixelSize: 14
                        font.capitalization: Font.AllUppercase
                        color: airbagOn ?
                               (Style.isDark ? "#4CAF50" : "#4CAF50") :
                               (Style.isDark ? Style.white : "#666666")
                        Behavior on color {
                            ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
                        }
                    }

                    Text {
                        id: statusText
                        text: airbagOn ? "SYSTEM ON" : "SYSTEM OFF"
                        font.family: "Inter"
                        font.bold: Font.Medium
                        font.pixelSize: 10
                        font.capitalization: Font.AllUppercase
                        color: airbagOn ?
                               (Style.isDark ? "#4CAF50" : "#4CAF50") :
                               (Style.isDark ? "#B0B0B0" : "#999999")
                        Behavior on color {
                            ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
                        }

                        // Pulsing animation when ON
                        opacity: airbagOn ? (0.6 + Math.sin(Date.now() / 400) * 0.4) : 1.0
                        Behavior on opacity {
                            NumberAnimation { duration: 800; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }
        }

        // Tooltip
        ToolTip {
            visible: airbagToggle.containsMouse
            delay: 500
            text: airbagOn ? "VITA System Active - Click to disable" : "VITA System Inactive - Click to enable"
            background: Rectangle {
                color: Style.isDark ? "#333333" : "white"
                radius: 6
                border.color: Style.isDark ? "#555555" : "#E0E0E0"
            }
        }
    }

    // Public functions
    function setTemperature(newTemp) {
        if (newTemp >= 60 && newTemp <= 90) {
            temp = newTemp;
            tempText.text = isCelsius ? convertToCelsius(temp) + "ºC" : temp + "ºF";
            temperatureChanged();
        }
    }

    function increaseTemperature() {
        if (temp < 90) setTemperature(temp + 1);
    }

    function decreaseTemperature() {
        if (temp > 60) setTemperature(temp - 1);
    }

    function toggleAirbag() {
        airbagOn = !airbagOn;
        airbagStatusChanged();
    }

    function setAirbagStatus(status) {
        airbagOn = status;
        airbagStatusChanged();
    }

    function toggleTemperatureUnit() {
        isCelsius = !isCelsius;
        tempText.text = isCelsius ? convertToCelsius(temp) + "ºC" : temp + "ºF";
    }

    function convertToCelsius(fahrenheit) {
        return Math.round((fahrenheit - 32) * 5/9);
    }

    function convertToFahrenheit(celsius) {
        return Math.round((celsius * 9/5) + 32);
    }

    property bool isCelsius: false

    // Signals
    signal temperatureChanged()
    signal airbagStatusChanged()
    signal timeClicked()

    Component.onCompleted: updateTime()
}
