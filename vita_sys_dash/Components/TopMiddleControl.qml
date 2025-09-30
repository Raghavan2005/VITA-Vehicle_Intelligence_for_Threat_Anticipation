import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Style 1.0

RowLayout {
    spacing: 32
    Icon {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        icon.source: "qrc:/icons/top_header_icons/dark/Sentry.svg"
        // Connect to main application safety slider
                   onClicked: {
                       // This assumes your main application has safetySlider id
                       if (typeof safetySlider !== "undefined") {
                           safetySlider.open();
                       }
                   }

                    // Tooltip
                    ToolTip.text: "Safety Systems"
                    ToolTip.visible: containsMouse
                    ToolTip.delay: 500
    }
    Icon {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        icon.source: "qrc:/icons/top_header_icons/dark/lock.svg"
        onClicked: Style.mapAreaVisible = ! Style.mapAreaVisible
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        spacing: 15

        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.pixelSize: 18
            font.bold: Font.DemiBold
            font.family: "Inter"
            color: Style.isDark ? Style.white : Style.black20
            text: qsTr("Vijay")
        }
    }


}
