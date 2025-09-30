import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0
import Qt5Compat.GraphicalEffects

Rectangle {
    id: toggleContainer
    width: 400
    height: 70
    color: "transparent"

    property string systemName: ""
    property string systemDescription: ""
    property bool defaultValue: true
    property bool systemEnabled: defaultValue
    property string systemIcon: "" // Optional icon path
    property color activeColor: "#4CAF50"
    property color inactiveColor: Style.isDark ? "#555555" : "#E0E0E0"
    property bool showStatus: true
    signal toggled(bool enabled)

    // Hover effect
    states: [
        State {
            name: "HOVERED"
            when: mouseArea.containsMouse
            PropertyChanges {
                target: bgRect
                color: Style.isDark ?
                       Style.alphaColor(Style.black, 0.4) :
                       Style.alphaColor(Style.white, 0.9)
                scale: 1.02
            }
        },
        State {
            name: "PRESSED"
            when: mouseArea.pressed
            PropertyChanges {
                target: bgRect
                color: Style.isDark ?
                       Style.alphaColor(Style.black, 0.5) :
                       Style.alphaColor(Style.white, 0.8)
                scale: 0.98
            }
        }
    ]

    transitions: Transition {
        NumberAnimation { properties: "scale"; duration: 150; easing.type: Easing.OutCubic }
        ColorAnimation { duration: 200 }
    }

    // Background with subtle border and shadow
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: Style.isDark ? Style.alphaColor(Style.black, 0.3) : Style.alphaColor(Style.white, 0.7)
        radius: 8
        border.color: Style.isDark ? Style.alphaColor(Style.white, 0.1) : Style.alphaColor(Style.black, 0.1)
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
            radius: 6
            samples: 13
            color: "#20000000"
        }
    }

    // Clickable area for entire component
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            systemToggle.toggle();
            rippleEffect.start();
        }
    }

    // Ripple effect on click
    Rectangle {
        id: rippleEffect
        property real size: 0
        property real opacityValue: 0.3

        anchors.centerIn: parent
        width: size
        height: size
        radius: width / 2
        color: systemEnabled ? activeColor : Style.isDark ? "#888888" : "#666666"
        opacity: opacityValue
        visible: false

        function start() {
            size = 0;
            opacityValue = 0.3;
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
                    to: Math.max(toggleContainer.width, toggleContainer.height) * 1.2
                    duration: 400
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: rippleEffect
                    property: "opacityValue"
                    from: 0.3
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

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        // Optional icon
        Rectangle {
            id: iconContainer
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 6
            color: systemEnabled ?
                   (Style.isDark ? Style.alphaColor(activeColor, 0.2) : Style.alphaColor(activeColor, 0.1)) :
                   (Style.isDark ? Style.alphaColor(Style.white, 0.1) : Style.alphaColor(Style.black, 0.05))
            visible: systemIcon !== ""
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                source: systemIcon
                sourceSize: Qt.size(18, 18)
                opacity: systemEnabled ? 1.0 : 0.6

                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: systemEnabled ? activeColor : (Style.isDark ? "#AAAAAA" : "#666666")
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    id: nameText
                    text: systemName
                    font.family: "Inter"
                    font.bold: Font.Medium
                    font.pixelSize: 14
                    color: systemEnabled ?
                           (Style.isDark ? activeColor : activeColor) :
                           (Style.isDark ? Style.white : Style.black20)
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Status badge
                Rectangle {
                    id: statusBadge
                    width: statusText.implicitWidth + 8
                    height: 16
                    radius: 8
                    color: systemEnabled ?
                           (Style.isDark ? Style.alphaColor(activeColor, 0.3) : Style.alphaColor(activeColor, 0.2)) :
                           (Style.isDark ? "#333333" : "#E0E0E0")
                    visible: showStatus
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: systemEnabled ? "ACTIVE" : "INACTIVE"
                        font.family: "Inter"
                        font.bold: Font.DemiBold
                        font.pixelSize: 9
                        font.capitalization: Font.AllUppercase
                        color: systemEnabled ? activeColor : (Style.isDark ? "#888888" : "#999999")
                    }
                }
            }

            Text {
                id: descText
                text: systemDescription
                font.family: "Inter"
                font.pixelSize: 11
                color: systemEnabled ?
                       (Style.isDark ? Style.alphaColor(activeColor, 0.8) : Style.alphaColor(activeColor, 0.7)) :
                       (Style.isDark ? Style.alphaColor(Style.white, 0.7) : Style.alphaColor(Style.black, 0.6))
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.maximumWidth: 280
            }
        }

        // Enhanced Toggle Switch
        Switch {
            id: systemToggle
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            checked: systemEnabled

            onCheckedChanged: {
                systemEnabled = checked;
                toggleContainer.toggled(systemEnabled);
            }

            // Custom styling with animations
            indicator: Rectangle {
                implicitWidth: 52
                implicitHeight: 26
                x: systemToggle.leftPadding
                y: parent.height / 2 - height / 2
                radius: 13
                color: systemToggle.checked ? activeColor : inactiveColor
                border.color: systemToggle.checked ?
                             Qt.darker(activeColor, 1.2) :
                             (Style.isDark ? "#666666" : "#CCCCCC")
                border.width: 2

                // Glow effect when active
                layer.enabled: systemToggle.checked
                layer.effect: Glow {
                    radius: 8
                    samples: 17
                    color: Style.alphaColor(activeColor, 0.4)
                    transparentBorder: true
                }

                Rectangle {
                    id: toggleHandle
                    x: systemToggle.checked ? parent.width - width - 3 : 3
                    y: 3
                    width: 20
                    height: 20
                    radius: 10
                    color: "white"

                    // Shadow for handle
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 1
                        radius: 3
                        samples: 7
                        color: "#40000000"
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: 200;
                            easing.type: Easing.OutBack;
                            easing.overshoot: 1.5
                        }
                    }
                }

                // Icon inside toggle
                Text {
                    anchors.centerIn: parent
                    text: systemToggle.checked ? "✓" : "✕"
                    font.pixelSize: 10
                    font.bold: true
                    color: systemToggle.checked ? "white" : (Style.isDark ? "#888888" : "#999999")
                    opacity: 0.8
                }

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on border.color {
                    ColorAnimation { duration: 300 }
                }
            }
        }
    }

    // Bottom separator with animation
    Rectangle {
        id: separator
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: systemEnabled ?
               Style.alphaColor(activeColor, 0.3) :
               (Style.isDark ? Style.alphaColor(Style.white, 0.1) : Style.alphaColor(Style.black, 0.1))

        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }

    // Tooltip for more info
    ToolTip {
        id: infoTooltip
        delay: 500
        text: systemDescription + "\n\nClick to " + (systemEnabled ? "disable" : "enable") + " this safety system."
        background: Rectangle {
            color: Style.isDark ? "#333333" : "white"
            radius: 6
            border.color: Style.isDark ? "#555555" : "#E0E0E0"
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8
                samples: 17
                color: "#40000000"
            }
        }
    }

    // Hover to show tooltip
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: infoTooltip.visible = true
        onExited: infoTooltip.visible = false
    }
}
