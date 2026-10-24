import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "clynx.uniform"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string note: ""

  readonly property string pasteHelper: Qt.resolvedUrl("paste.sh").toString().replace(/^file:\/\//, "")
  readonly property color ink: bar ? bar.foreground : Commons.Color.foreground
  readonly property color dim: Qt.darker(ink, 1.45)
  readonly property int readingHeight: {
    var cap = Style.space(561)
    var floor = Style.space(180)
    var available = panel.availableCardHeight
    if (!(available > 0)) return cap
    return Math.max(floor, Math.min(cap, available - Style.space(150)))
  }

  function showPaste(raw) {
    var parsed = Model.payload(raw)
    var cleaned = parsed.kind === "html" ? Model.uniformHtml(parsed.body) : Model.uniformPlain(parsed.body)
    editor.text = cleaned
    Qt.callLater(function() { scroller.contentY = 0 })
    note = cleaned === "" ? "Nothing on the clipboard" : "Pasted"
  }

  function pasteFromClipboard() {
    if (pasteProc.running) return
    pasteProc.running = true
  }

  function copyPlain() {
    if (editor.text === "") {
      note = "Nothing to copy"
      return
    }
    if (copyProc.running) return
    copyProc.payload = editor.text
    copyProc.stdinEnabled = true
    copyProc.running = true
  }

  function clearText() {
    editor.text = ""
    note = "Cleared"
  }

  function switchPanel(direction) {
    if (bar && typeof bar.switchPanelFrom === "function")
      return bar.switchPanelFrom(hostWidget || root, direction)
    return false
  }

  onOpenedChanged: {
    if (!opened) return
    pasteFromClipboard()
  }

  Process {
    id: pasteProc
    command: ["bash", root.pasteHelper]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.showPaste(text)
    }
    onExited: function(code) {
      if (code !== 0) root.showPaste("")
    }
  }

  Process {
    id: copyProc
    property string payload: ""
    command: ["wl-copy", "--type", "text/plain"]
    onStarted: {
      write(payload)
      payload = ""
      stdinEnabled = false
      root.note = "Copied as plain text"
    }
    onExited: function(code) {
      if (code !== 0) root.note = "Could not copy"
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(685))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: editor.activeFocus
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(12)

        Column {
          width: parent.width
          spacing: Style.space(2)

          Text {
            text: "Uniform"
            textFormat: Text.PlainText
            color: root.ink
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            text: "Website and AI text, in one font"
            textFormat: Text.PlainText
            color: root.dim
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }

        Row {
          spacing: Style.space(8)

          Button {
            text: "Paste"
            bordered: true
            foreground: root.ink
            fontFamily: Style.font.family
            enabled: !pasteProc.running
            onClicked: root.pasteFromClipboard()
          }

          Button {
            text: "Copy"
            bordered: true
            foreground: root.ink
            fontFamily: Style.font.family
            onClicked: root.copyPlain()
          }

          Button {
            text: "Clear"
            bordered: true
            foreground: root.ink
            fontFamily: Style.font.family
            onClicked: root.clearText()
          }
        }

        Item {
          id: reader
          width: column.width
          height: root.readingHeight
          implicitHeight: height

          Rectangle {
            anchors.fill: parent
            color: Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.06)
            radius: Style.cornerRadius
            border.width: 1
            border.color: Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.18)
          }

          Flickable {
            id: scroller
            anchors.fill: parent
            anchors.margins: 1
            anchors.rightMargin: Style.space(16)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            interactive: true
            contentWidth: width
            contentHeight: editor.implicitHeight

            Text {
              id: editor
              width: scroller.width
              textFormat: Text.PlainText
              wrapMode: Text.Wrap
              color: root.ink
              font.family: Style.font.family
              font.pixelSize: Math.round(Style.font.body * 1.331)
              font.bold: false
              font.italic: false
              leftPadding: Style.space(10)
              rightPadding: Style.space(4)
              topPadding: Style.space(8)
              bottomPadding: Style.space(8)
            }
          }

          ScrollBar {
            id: vbar
            anchors.top: scroller.top
            anchors.bottom: scroller.bottom
            anchors.right: reader.right
            anchors.rightMargin: 3
            width: Style.space(10)
            orientation: Qt.Vertical
            policy: scroller.contentHeight > scroller.height + 1 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            minimumSize: 0.08
            size: scroller.visibleArea.heightRatio
            contentItem: Rectangle {
              radius: width / 2
              color: "#d7d7d7"
            }
            background: Rectangle {
              radius: width / 2
              color: "#3a3a3a"
            }

            Binding {
              target: vbar
              property: "position"
              value: scroller.visibleArea.yPosition
              when: !vbar.pressed
            }
            onPositionChanged: {
              if (!pressed) return
              var span = Math.max(0, scroller.contentHeight - scroller.height)
              scroller.contentY = position * span / Math.max(0.001, 1 - size)
            }
          }

          Text {
            visible: editor.text === ""
            x: Style.space(10)
            y: Style.space(8)
            width: parent.width - x - Style.space(16)
            text: "Copy from a page or an answer, then press Paste."
            textFormat: Text.PlainText
            color: root.dim
            font.family: Style.font.family
            font.pixelSize: Math.round(Style.font.body * 1.331)
            wrapMode: Text.WordWrap
          }
        }

        Text {
          width: parent.width
          text: {
            var n = Model.words(editor.text)
            var count = n === 1 ? "1 word" : n + " words"
            return root.note === "" ? count : count + "  ·  " + root.note
          }
          textFormat: Text.PlainText
          color: root.dim
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }
    }
  }
}
