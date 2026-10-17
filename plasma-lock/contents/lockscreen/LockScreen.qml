import QtQuick
import QtQuick.Controls as Controls
import org.kde.kscreenlocker 1.0 as ScreenLocker
import org.kde.plasma.private.sessions 2.0

FocusScope {
    id: root
    width: 1600
    height: 900
    focus: true
    property bool locked: true
    property bool capsLockOn: false
    signal unlockRequested()

    readonly property color ivory: "#dafce6"
    readonly property color acid: "#87ffb0"
    readonly property color faded: "#96bda5"
    readonly property color quiet: "#587960"
    readonly property color danger: "#ff938b"
    readonly property string mono: "DejaVu Sans Mono"
    readonly property bool compact: width < 780 || height < 620
    readonly property real margin: Math.max(22, Math.min(72, width * 0.048))
    property bool backupMode: false
    property bool waitingForSecret: false
    property bool authSucceeded: false
    property string problem: ""
    property date now: new Date()

    function useKdeFallback() {
        if (root.backupMode) return
        if (root.waitingForSecret && authenticator.busy) {
            authenticator.respond("")
        }
        root.waitingForSecret = false
        root.backupMode = true
        pass.text = ""
    }
    function startOrReply() {
        if (root.backupMode || root.authSucceeded || authenticator.graceLocked) return
        root.problem = ""
        if (root.waitingForSecret) {
            root.waitingForSecret = false
            authenticator.respond(pass.text)
        } else if (!authenticator.busy) {
            authenticator.startAuthenticating()
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_F12) {
            root.useKdeFallback()
            event.accepted = true
        }
    }
    Shortcut {
        sequence: "F12"
        context: Qt.ApplicationShortcut
        onActivated: root.useKdeFallback()
    }

    Rectangle { anchors.fill: parent; color: "#020904" }
    RainEngine {
        id: rain
        anchors.fill: parent
        quality: 2
        density: 0.90
        intensity: 1.00
        animate: !root.backupMode
        visible: !root.backupMode
    }

    Item {
        id: visual
        anchors.fill: parent
        visible: !root.backupMode

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
        Timer { interval: 10000; running: visual.visible; repeat: true; onTriggered: root.now = new Date() }
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
                color: root.ivory; font.family: root.mono
                font.pixelSize: root.compact ? 24 : 30
                font.weight: Font.Medium; font.letterSpacing: 0.45
            }
            Text {
                x: 0; y: 98
                text: "Unlock the current KDE Plasma session."
                color: root.faded; font.family: root.mono
                font.pixelSize: 11
            }
            Text {
                x: 0; y: 148
                text: "01    SESSION OWNER"
                color: root.faded; font.family: root.mono
                font.pixelSize: 10; font.letterSpacing: 1.1
            }
            Text {
                x: 0; y: 171
                width: auth.width
                text: kscreenlocker_userName || qsTr("CURRENT USER")
                elide: Text.ElideRight
                color: root.ivory; font.family: root.mono
                font.pixelSize: 21; font.weight: Font.Medium
            }
            Rectangle { x: 0; y: 209; width: auth.width; height: 1; color: "#63856c" }

            Text {
                x: 0; y: 257
                text: "02    PASSPHRASE"
                color: root.faded; font.family: root.mono
                font.pixelSize: 10; font.letterSpacing: 1.1
            }
            Controls.TextField {
                id: pass
                x: 0; y: 275; width: auth.width; height: 45
                enabled: !root.authSucceeded && !authenticator.graceLocked
                echoMode: TextInput.Password; passwordCharacter: "●"
                passwordMaskDelay: 0
                placeholderText: authenticator.promptForSecret || "Password"
                placeholderTextColor: root.quiet
                color: root.ivory; selectionColor: "#2f8b55"; selectedTextColor: "#ffffff"
                font.family: root.mono; font.pixelSize: 18; font.letterSpacing: 2
                verticalAlignment: TextInput.AlignVCenter
                leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                selectByMouse: true
                background: Rectangle {
                    color: "transparent"
                    Rectangle {
                        anchors.bottom: parent.bottom; width: parent.width
                        height: pass.activeFocus ? 2 : 1
                        color: pass.activeFocus ? root.acid : "#63856c"
                    }
                }
                onAccepted: root.startOrReply()
                onTextEdited: root.problem = ""
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_F12) {
                        root.useKdeFallback()
                        event.accepted = true
                    }
                }
            }
            Text {
                x: 0; y: 350
                width: auth.width - 145
                text: root.problem.length > 0 ? root.problem :
                      (root.capsLockOn ? "CAPS LOCK ENABLED" :
                      (authenticator.busy ? (root.waitingForSecret ? "AWAITING PASSPHRASE" : "VERIFYING CREDENTIALS…") : "SYSTEM READY  /  SECURE"))
                color: root.problem.length > 0 ? root.danger : (root.capsLockOn ? "#e9cb77" : root.quiet)
                font.family: root.mono; font.pixelSize: 9; font.letterSpacing: 0.5
                elide: Text.ElideRight
            }
            FlatAction {
                x: auth.width - width; y: 335
                height: 44; text: authenticator.busy && !root.waitingForSecret ? "VERIFYING…" : "UNLOCK   ↗"
                accent: root.acid; primary: true
                enabled: !root.authSucceeded && !authenticator.graceLocked && (!authenticator.busy || root.waitingForSecret)
                onClicked: root.startOrReply()
            }
            Component.onCompleted: pass.forceActiveFocus()
        }
        Rectangle {
            x: root.margin; y: root.height - 83
            width: root.width - 2 * root.margin; height: 1
            color: "#295239"; opacity: 0.9
        }
        Text {
            x: root.margin; y: root.height - 114
            text: "TERMINAL  /  03                         ENCRYPTED SESSION"
            color: root.quiet; font.family: root.mono; font.pixelSize: 9
            font.letterSpacing: 0.8; visible: !root.compact
        }
        Row {
            x: root.margin - 8; y: root.height - 74
            spacing: 4
            FlatAction {
                text: "FINGERPRINT"
                visible: (authenticator.authenticatorTypes & ScreenLocker.Authenticator.Fingerprint) && !root.compact
                onClicked: root.startOrReply()
            }
            FlatAction {
                text: "SWITCH USER"
                visible: sessionMan.canSwitchUser
                onClicked: sessionMan.switchUser()
            }
        }
        Row {
            x: root.width - width - root.margin + 8
            y: root.height - 74
            spacing: root.compact ? 0 : 4
            FlatAction { text: "KDE DEFAULT  ↗"; onClicked: root.useKdeFallback() }
        }
        Text {
            x: root.width - root.margin - width
            y: root.height - 112
            text: "F12  /  SAFE UNLOCK"
            color: root.quiet; font.family: root.mono; font.pixelSize: 9
            font.letterSpacing: 0.5
        }
    }

    SessionManagement { id: sessionMan }

    Loader {
        id: kdeNative
        anchors.fill: parent
        active: root.backupMode
        visible: root.backupMode
        z: 100
        source: "qrc:/fallbacktheme/LockScreen.qml"
        focus: root.backupMode
        onLoaded: {
            if (item) {
                item.locked = root.locked
                item.forceActiveFocus()
            }
        }
        onStatusChanged: {
            if (root.backupMode && status === Loader.Error) {
                root.problem = "KDE FALLBACK UNAVAILABLE; TRY CTRL+ALT+F3 TO RESTORE"
                root.backupMode = false
            }
        }
    }
    onLockedChanged: {
        if (kdeNative.item) kdeNative.item.locked = root.locked
    }

    Connections {
        target: root.backupMode ? null : authenticator
        function onPromptForSecretChanged() {
            if (root.backupMode) return
            if (pass.text.length) {
                root.waitingForSecret = false
                authenticator.respond(pass.text)
            } else {
                root.waitingForSecret = true
                pass.forceActiveFocus()
            }
        }
        function onFailed() {
            root.waitingForSecret = false
            root.problem = qsTr("AUTHENTICATION FAILED  /  TRY AGAIN")
            pass.clear()
            pass.forceActiveFocus()
        }
        function onSucceeded() {
            root.authSucceeded = true
            pass.clear()
            Qt.quit()
        }
        function onBusyChanged() {
            if (!authenticator.busy) {
                root.waitingForSecret = false
                if (!root.authSucceeded) pass.forceActiveFocus()
            }
        }
        function onErrorMessageChanged() {
            if (authenticator.errorMessage) root.problem = authenticator.errorMessage
        }
        function onInfoMessageChanged() {
            if (authenticator.infoMessage) root.problem = authenticator.infoMessage
        }
    }
    Component.onCompleted: {
        if (authenticator.authenticatorTypes & (ScreenLocker.Authenticator.Fingerprint | ScreenLocker.Authenticator.Smartcard)) {
            authenticator.startAuthenticating()
        }
        pass.forceActiveFocus()
    }
}
