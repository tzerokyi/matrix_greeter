import QtQuick
import QtQuick.Controls as Controls

FocusScope {
    id: root
    width: 1600
    height: 900
    focus: true

    readonly property color ivory: "#dafce6"
    readonly property color acid: "#87ffb0"
    readonly property color faded: "#96bda5"
    readonly property color quiet: "#587960"
    readonly property color danger: "#ff938b"
    readonly property string mono: "DejaVu Sans Mono"
    readonly property bool compact: width < 780 || height < 620
    readonly property real margin: Math.max(22, Math.min(72, width * 0.048))
    readonly property int preset: isNaN(Number(config.rainQuality)) ? 2 : Math.max(0, Math.min(2, Number(config.rainQuality)))
    readonly property real rainDensity: isNaN(Number(config.rainDensity)) ? 0.9 : Math.max(0.0, Math.min(1.0, Number(config.rainDensity)))
    readonly property real rainBrightness: isNaN(Number(config.rainBrightness)) ? 1.0 : Math.max(0.3, Math.min(1.7, Number(config.rainBrightness)))
    readonly property bool useMotion: String(config.rainMotion).toLowerCase() !== "false"

    property bool authenticating: false
    property bool customUser: userModel.count === 0
    property string problem: ""
    property string pendingPower: ""
    property date now: new Date()

    function doLogin() {
        if (root.authenticating) return
        var account = root.customUser ? manualUser.text.trim() : userCombo.currentText
        if (account.length === 0) {
            root.problem = qsTr("ENTER A USERNAME")
            manualUser.forceActiveFocus()
            return
        }
        root.problem = ""
        root.authenticating = true
        sddm.login(account, password.text, Math.max(0, sessionCombo.currentIndex))
    }

    function askPower(operation) {
        if (root.authenticating) return
        root.pendingPower = operation
        confirmDialog.open()
    }

    function doPower() {
        var op = root.pendingPower
        confirmDialog.close()
        if (op === "reboot") sddm.reboot()
        else if (op === "poweroff") sddm.powerOff()
    }

    Rectangle { anchors.fill: parent; color: "#020904" }

    RainEngine {
        anchors.fill: parent
        quality: root.preset
        density: root.rainDensity
        intensity: root.rainBrightness
        animate: root.useMotion
    }

    Item {
        id: topBar
        x: root.margin
        y: Math.max(26, root.height * 0.066)
        width: root.width - root.margin * 2
        height: 72

        Rectangle { x: 0; y: 1; width: 9; height: 9; color: root.acid }
        Rectangle { x: 3; y: 4; width: 3; height: 3; color: "#001d08" }
        Rectangle { x: 108; y: 2; width: 1; height: 17; color: "#477255"; visible: !root.compact }
        Text {
            x: 123; y: 0; visible: !root.compact
            text: "MATRIX // 03"; color: root.acid
            font.family: root.mono; font.pixelSize: 11; font.letterSpacing: 2.0
        }
        Text {
            x: 26; y: 31; visible: !root.compact
            text: "ARCH LINUX     /     SECURE ACCESS TERMINAL"
            color: root.quiet; font.family: root.mono; font.pixelSize: 9
            font.letterSpacing: 1.35
        }
        Column {
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 4
            Text {
                anchors.right: parent.right
                text: Qt.formatTime(root.now, "HH:mm")
                color: root.ivory; font.family: root.mono
                font.pixelSize: root.compact ? 24 : 32
                font.weight: Font.Light; font.letterSpacing: -1.6
            }
            Text {
                anchors.right: parent.right
                text: Qt.formatDate(root.now, "ddd · dd MMM yyyy").toUpperCase()
                color: root.faded; font.family: root.mono
                font.pixelSize: 9; font.letterSpacing: 1
                visible: !root.compact
            }
        }
    }

    Timer {
        interval: 10000; running: true; repeat: true
        onTriggered: root.now = new Date()
    }

    Rectangle {
        x: root.margin; y: root.height * 0.195
        width: 1; height: Math.max(0, root.height * 0.16)
        color: "#2b633b"; opacity: 0.65
        visible: !root.compact
    }
    Text {
        x: root.margin + 10; y: root.height * 0.23
        text: "AUTH / 001"; color: root.quiet
        font.family: root.mono; font.pixelSize: 9; font.letterSpacing: 1
        rotation: 90; transformOrigin: Item.TopLeft
        visible: !root.compact
    }

    FocusScope {
        id: auth
        width: Math.min(448, root.width - 56)
        height: 391
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.compact ? 0 : 15
        scale: root.height < 670 ? Math.max(0.72, root.height / 710) : 1
        transformOrigin: Item.Center
        focus: true

        Row {
            x: 0; y: 0; spacing: 10
            Rectangle { width: 5; height: 5; y: 4; color: root.acid }
            Text {
                text: "IDENTITY VERIFICATION"; color: root.acid
                font.family: root.mono; font.pixelSize: 10
                font.bold: true; font.letterSpacing: 2.0
            }
        }
        Rectangle { x: 0; y: 28; height: 1; width: 40; color: root.acid }
        Rectangle { x: 52; y: 28; height: 1; width: auth.width - 52; color: "#275239"; opacity: 0.9 }

        Text {
            x: -2; y: 48
            text: "WAKE THE SYSTEM"
            color: root.ivory
            font.family: root.mono
            font.pixelSize: root.compact ? 24 : 30
            font.weight: Font.Medium
            font.letterSpacing: 0.45
        }
        Text {
            x: 0; y: 98
            text: "Enter your credentials to continue."
            color: root.faded; font.family: root.mono
            font.pixelSize: 11
        }

        Text {
            x: 0; y: 148
            text: "01    USERNAME"
            color: root.faded; font.family: root.mono
            font.pixelSize: 10; font.letterSpacing: 1.1
        }
        Controls.ComboBox {
            id: userCombo
            x: 0; y: 166
            width: auth.width; height: 43
            visible: !root.customUser
            enabled: !root.authenticating
            model: userModel; textRole: "name"
            currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
            hoverEnabled: true
            contentItem: Text {
                text: userCombo.displayText
                color: root.ivory; font.family: root.mono
                font.pixelSize: 21; font.weight: Font.Medium
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            indicator: Text {
                x: userCombo.width - width - 4; y: 7
                text: "⌄"; color: root.acid
                font.pixelSize: 20; visible: userCombo.count > 1
            }
            background: Rectangle {
                color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; height: userCombo.activeFocus ? 2 : 1; width: parent.width; color: userCombo.activeFocus ? root.acid : "#63856c" }
            }
            delegate: Controls.ItemDelegate {
                width: userCombo.width; height: 40
                hoverEnabled: true
                contentItem: Text {
                    text: userCombo.textAt(index)
                    leftPadding: 12; verticalAlignment: Text.AlignVCenter
                    color: userCombo.highlightedIndex === index ? root.acid : root.ivory
                    font.family: root.mono; font.pixelSize: 12
                }
                background: Rectangle { color: userCombo.highlightedIndex === index ? "#173b26" : "#03130a" }
            }
            popup: Controls.Popup {
                y: userCombo.height; width: userCombo.width; padding: 1
                implicitHeight: Math.min(242, usersList.contentHeight + 2)
                contentItem: ListView {
                    id: usersList; clip: true
                    implicitHeight: Math.min(contentHeight, 240)
                    model: userCombo.popup.visible ? userCombo.delegateModel : null
                    currentIndex: userCombo.highlightedIndex
                    Controls.ScrollIndicator.vertical: Controls.ScrollIndicator { }
                }
                background: Rectangle { color: "#03130a"; border.color: "#366c46"; border.width: 1 }
            }
            onActivated: password.forceActiveFocus()
        }
        Controls.TextField {
            id: manualUser
            x: 0; y: 166; width: auth.width; height: 43
            visible: root.customUser; enabled: !root.authenticating
            text: userModel.count === 0 ? userModel.lastUser : ""
            placeholderText: "Username"; placeholderTextColor: root.quiet
            color: root.ivory; selectionColor: "#2f8b55"; selectedTextColor: "#ffffff"
            font.family: root.mono; font.pixelSize: 21
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
            selectByMouse: true
            background: Rectangle {
                color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: manualUser.activeFocus ? 2 : 1; color: manualUser.activeFocus ? root.acid : "#63856c" }
            }
            onAccepted: password.forceActiveFocus()
            onTextEdited: root.problem = ""
        }

        FlatAction {
            x: auth.width - width; y: 211
            text: root.customUser ? "BACK TO USERS ↩" : "OTHER USER ↗"
            visible: userModel.count > 0
            enabled: !root.authenticating
            onClicked: {
                root.customUser = !root.customUser
                root.problem = ""
                if (root.customUser) {
                    manualUser.text = ""
                    manualUser.forceActiveFocus()
                } else password.forceActiveFocus()
            }
        }

        Text {
            x: 0; y: 257
            text: "02    PASSPHRASE"
            color: root.faded; font.family: root.mono
            font.pixelSize: 10; font.letterSpacing: 1.1
        }
        Controls.TextField {
            id: password
            x: 0; y: 275; width: auth.width; height: 45
            enabled: !root.authenticating
            echoMode: TextInput.Password; passwordCharacter: "●"
            passwordMaskDelay: 0
            placeholderText: "Password"; placeholderTextColor: root.quiet
            color: root.ivory; selectionColor: "#2f8b55"; selectedTextColor: "#ffffff"
            font.family: root.mono; font.pixelSize: 18; font.letterSpacing: 2
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
            selectByMouse: true
            background: Rectangle {
                color: "transparent"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: password.activeFocus ? 2 : 1; color: password.activeFocus ? root.acid : "#63856c" }
            }
            onAccepted: root.doLogin()
            onTextEdited: root.problem = ""
        }

        Text {
            x: 0; y: 350
            width: auth.width - 145
            text: root.problem.length > 0 ? root.problem :
                  (keyboard.capsLock ? "CAPS LOCK ENABLED" : (root.authenticating ? "VERIFYING CREDENTIALS…" : "SYSTEM READY  /  SECURE"))
            color: root.problem.length > 0 ? root.danger : (keyboard.capsLock ? "#e9cb77" : root.quiet)
            font.family: root.mono; font.pixelSize: 9; font.letterSpacing: 0.5
            elide: Text.ElideRight
        }
        FlatAction {
            x: auth.width - width; y: 335
            height: 44; text: root.authenticating ? "VERIFYING…" : "SIGN IN   ↗"
            accent: root.acid; primary: true
            enabled: !root.authenticating
            onClicked: root.doLogin()
        }
        Component.onCompleted: {
            if (root.customUser && manualUser.text.length === 0) manualUser.forceActiveFocus()
            else password.forceActiveFocus()
        }
    }

    Rectangle {
        x: root.margin; y: root.height - 83
        width: root.width - 2 * root.margin
        height: 1; color: "#295239"; opacity: 0.9
    }
    Text {
        x: root.margin; y: root.height - 114
        text: "TERMINAL  /  03                         ENCRYPTED SESSION"
        color: root.quiet; font.family: root.mono; font.pixelSize: 9
        font.letterSpacing: 0.8; visible: !root.compact
    }
    Row {
        id: utilities
        x: root.margin - 8
        y: root.height - 74
        spacing: root.compact ? 0 : 4
        Controls.ComboBox {
            id: sessionCombo
            width: Math.min(230, Math.max(135, root.width * 0.19))
            height: 44; model: sessionModel; textRole: "name"
            currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
            hoverEnabled: true
            contentItem: Text {
                text: "SESSION  /  " + sessionCombo.displayText.toUpperCase()
                color: sessionCombo.hovered ? root.acid : root.faded
                font.family: root.mono; font.pixelSize: 10; font.letterSpacing: 0.25
                verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
            }
            indicator: Text {
                x: sessionCombo.width - width - 4; y: 9
                text: "⌄"; color: root.acid; font.pixelSize: 16
            }
            background: Rectangle { color: "transparent" }
            delegate: Controls.ItemDelegate {
                width: sessionCombo.width; height: 40; hoverEnabled: true
                contentItem: Text {
                    text: sessionCombo.textAt(index); leftPadding: 10
                    verticalAlignment: Text.AlignVCenter; font.family: root.mono; font.pixelSize: 12
                    color: sessionCombo.highlightedIndex === index ? root.acid : root.ivory
                }
                background: Rectangle { color: sessionCombo.highlightedIndex === index ? "#153722" : "#03130a" }
            }
            popup: Controls.Popup {
                y: -Math.min(242, sessionList.contentHeight + 2)
                width: sessionCombo.width; padding: 1
                implicitHeight: Math.min(242, sessionList.contentHeight + 2)
                contentItem: ListView {
                    id: sessionList; clip: true
                    implicitHeight: Math.min(contentHeight, 240)
                    model: sessionCombo.popup.visible ? sessionCombo.delegateModel : null
                    currentIndex: sessionCombo.highlightedIndex
                    Controls.ScrollIndicator.vertical: Controls.ScrollIndicator { }
                }
                background: Rectangle { color: "#03130a"; border.width: 1; border.color: "#366c46" }
            }
            onActivated: password.forceActiveFocus()
        }
        FlatAction {
            text: "KEYBOARD"
            visible: keyboard.layouts.length > 1 && !root.compact
            onClicked: layoutPopup.open()
            Controls.Popup {
                id: layoutPopup; width: 235; padding: 2
                y: -Math.min(260, layoutList.contentHeight + 8)
                implicitHeight: Math.min(260, layoutList.contentHeight + 8)
                contentItem: ListView {
                    id: layoutList; width: 231; clip: true
                    implicitHeight: Math.min(contentHeight, 254)
                    model: keyboard.layouts
                    delegate: FlatAction {
                        width: 231; height: 36; text: modelData.longName
                        onClicked: {
                            keyboard.currentLayout = index
                            layoutPopup.close()
                            password.forceActiveFocus()
                        }
                    }
                }
                background: Rectangle { color: "#03130a"; border.width: 1; border.color: "#366c46" }
            }
        }
        FlatAction {
            text: "ON-SCREEN"
            visible: !root.compact
            onClicked: {
                password.forceActiveFocus()
                if (Qt.inputMethod.visible) Qt.inputMethod.hide()
                else Qt.inputMethod.show()
            }
        }
    }

    Row {
        x: root.width - width - root.margin + 8
        y: root.height - 74
        spacing: root.compact ? 0 : 4
        FlatAction { text: "SLEEP"; visible: sddm.canSuspend && !root.compact; onClicked: sddm.suspend() }
        FlatAction { text: "HIBERNATE"; visible: sddm.canHibernate && !root.compact; onClicked: sddm.hibernate() }
        FlatAction { text: "RESTART"; visible: sddm.canReboot; onClicked: root.askPower("reboot") }
        FlatAction { text: "SHUT DOWN"; visible: sddm.canPowerOff; onClicked: root.askPower("poweroff") }
    }

    Controls.Popup {
        id: confirmDialog
        modal: true; focus: true
        parent: Controls.Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(410, root.width - 40)
        height: 196; padding: 25
        closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside
        background: Rectangle { color: "#03120a"; border.width: 1; border.color: "#69b780" }
        contentItem: Item {
            Text {
                x: 0; y: 0
                text: "CONFIRM  /  " + (root.pendingPower === "reboot" ? "RESTART" : "SHUT DOWN")
                color: root.acid; font.family: root.mono
                font.pixelSize: 13; font.bold: true; font.letterSpacing: 1
            }
            Text {
                x: 0; y: 47
                text: root.pendingPower === "reboot" ? "Restart this computer?" : "Power off this computer?"
                color: root.ivory; font.family: root.mono; font.pixelSize: 12
            }
            Row {
                anchors.right: parent.right; anchors.bottom: parent.bottom
                spacing: 12
                FlatAction { text: "CANCEL"; onClicked: confirmDialog.close() }
                FlatAction { text: "CONFIRM ↗"; primary: true; onClicked: root.doPower() }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.authenticating = false
            root.problem = qsTr("AUTHENTICATION FAILED  /  TRY AGAIN")
            password.clear()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            root.problem = ""
        }
    }
}
