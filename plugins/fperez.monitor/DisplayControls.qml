import QtQuick
import QtQuick.Controls as Controls
import qs.Ui
import qs.Commons as Commons
import "Model.js" as Model

Column {
  id: editor
  required property var outputs
  required property string selectedName
  required property bool busy
  required property bool failed
  signal selected(string name)
  required property bool showNumbers
  signal toggleNumbers()
  signal setEnabled(string name, bool enabled)
  signal applyRules(var rules)

  spacing: Commons.Style.space(8)
  readonly property var output: outputs.find(d => d.name === selectedName)
  readonly property var activeOutputs: outputs.filter(d => !d.disabled)
  readonly property var availableModes: output && !output.disabled ? Model.modes(output) : []
  readonly property var rects: activeOutputs.filter(d => d.mirrorOf === "none" || !d.mirrorOf).map(Model.logicalRect)

  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function outputTitle(display, index) {
    return strings.t("display.name").arg(index + 1).arg(display.model || display.description || display.name).arg(display.name)
  }

  function outputNumber(name) {
    return outputs.findIndex(d => d.name === name) + 1
  }

  function applyChanges(changes) {
    let layout = rects
    let moved = false
    for (const change of changes) {
      const old = layout.find(rect => rect.name === change.name)
      if (!old || layout.length < 2) continue
      const resized = Model.logicalRect({name: change.name, width: change.width, height: change.height,
        x: old.x, y: old.y, scale: change.scale, transform: change.transform})
      if (resized.w === old.w && resized.h === old.h) continue
      const next = Model.dropDisplay(layout.map(rect => rect.name === change.name ? resized : rect),
        change.name, old.x, old.y, 0)
      if (!next) return
      layout = next
      moved = true
    }

    const rules = changes.map(change => {
      const position = moved && layout.find(rect => rect.name === change.name)
      const placement = position ? ', position="' + position.x + "x" + position.y + '"' : ""
      return 'hl.monitor({output="' + change.name + '", ' + change.fields + placement + '})'
    })
    if (moved) {
      for (const rect of layout) {
        if (!changes.some(change => change.name === rect.name)) rules.push(Model.layoutRule(rect))
      }
    }
    applyRules(rules)
  }

  function modeChange(display, mode) {
    if (!mode) return null
    const scale = Model.cleanScale(display.scale, mode.width, mode.height)
    if (!scale) return null
    return {name: display.name, fields: 'mode="' + mode.value + '", scale=' + scale,
      width: mode.width, height: mode.height, transform: display.transform, scale: Number(scale)}
  }

  PanelSectionHeader {
    width: parent.width
    text: strings.t("display.settings")
  }

  Button {
    text: strings.t(editor.showNumbers ? "display.hideNumbers" : "display.showNumbers")
    bordered: true
    onClicked: editor.toggleNumbers()
  }

  DisplayCombo {
    id: displayPicker
    width: parent.width
    label: strings.t("display.settings")
    model: editor.outputs.map(editor.outputTitle)
    currentIndex: editor.outputNumber(editor.selectedName) - 1
    onActivated: function(index) { editor.selected(editor.outputs[index].name) }
  }

  Button {
    visible: !!editor.output
    enabled: !!editor.output && !editor.busy && (editor.output.disabled || editor.activeOutputs.length > 1)
    text: strings.t(editor.output && editor.output.disabled ? "display.enable" : "display.disable")
    bordered: true
    onClicked: editor.setEnabled(editor.output.name, !!editor.output.disabled)
  }

  DisplayText {
    visible: orientationPicker.visible
    text: strings.t("display.orientation")
  }

  DisplayCombo {
    id: orientationPicker
    width: parent.width
    label: strings.t("display.orientation")
    visible: !!editor.output && !editor.output.disabled
    enabled: !editor.busy
    model: [strings.t("display.landscape"), strings.t("display.portrait"),
      strings.t("display.landscapeFlipped"), strings.t("display.portraitFlipped")]
    currentIndex: editor.output && editor.output.transform < 4 ? editor.output.transform : -1
    onActivated: function(index) {
      const display = editor.output
      editor.applyChanges([{name: display.name, fields: "transform=" + index,
        width: display.width, height: display.height, transform: index, scale: display.scale}])
    }
  }

  DisplayText {
    text: strings.t("display.mode")
    visible: modePicker.visible
  }

  DisplayCombo {
    id: modePicker
    width: parent.width
    label: strings.t("display.mode")
    enabled: !editor.busy
    visible: editor.availableModes.length > 0
    model: [strings.t("display.maximum")].concat(editor.availableModes.map(mode =>
      strings.t("display.modeValue").arg(mode.width).arg(mode.height).arg(mode.rate)))
    currentIndex: {
      if (!editor.output) return -1
      const display = editor.output
      const index = editor.availableModes.findIndex(mode => mode.width === display.width
        && mode.height === display.height && Math.abs(mode.rate - display.refreshRate) < 0.1)
      return index < 0 ? -1 : index + 1
    }
    onActivated: function(index) {
      const change = editor.modeChange(editor.output, editor.availableModes[Math.max(0, index - 1)])
      if (change) editor.applyChanges([change])
    }
  }

  Button {
    visible: editor.activeOutputs.length > 1
    enabled: !editor.busy && editor.activeOutputs.some(d => Model.modes(d).length > 0)
    text: strings.t("display.maximumAll")
    bordered: true
    onClicked: editor.applyChanges(editor.activeOutputs.map(d => editor.modeChange(d, Model.modes(d)[0])).filter(Boolean))
  }

  DisplayText {
    visible: layoutMap.visible
    text: strings.t("display.arrange")
  }

  Rectangle {
    id: layoutMap
    width: parent.width
    height: Commons.Style.space(180)
    visible: editor.rects.length > 1
    readonly property var bounds: Model.layoutBounds(editor.rects)
    readonly property real ratio: Math.min(width / (bounds.w * 1.65), height / (bounds.h * 1.65))
    readonly property real originX: (width - bounds.w * ratio) / 2
    readonly property real originY: (height - bounds.h * ratio) / 2
    radius: Commons.Style.cornerRadius
    color: Commons.Color.popups.background
    border.color: Qt.darker(Commons.Color.foreground, 1.7)
    clip: true

    Repeater {
      // Keep delegates alive during state polling and while dragging.
      model: editor.rects.length
      Rectangle {
        id: tile
        required property int index
        readonly property var rect: editor.rects[index]
        property real dx: 0
        property real dy: 0
        x: layoutMap.originX + (rect.x - layoutMap.bounds.x) * layoutMap.ratio + dx
        y: layoutMap.originY + (rect.y - layoutMap.bounds.y) * layoutMap.ratio + dy
        width: Math.max(4, rect.w * layoutMap.ratio - 2)
        height: Math.max(4, rect.h * layoutMap.ratio - 2)
        z: drag.pressed ? 1 : 0
        color: Commons.Style.selectedFillFor(Commons.Color.foreground, Commons.Color.accent)
        border.color: rect.name === editor.selectedName ? Commons.Color.accent : Qt.darker(Commons.Color.foreground, 1.4)

        DisplayText {
          anchors.fill: parent
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
          text: editor.outputNumber(tile.rect.name)
        }

        MouseArea {
          id: drag
          anchors.fill: parent
          enabled: !editor.busy
          preventStealing: true
          cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
          property point start
          onPressed: function(mouse) {
            start = mapToItem(layoutMap, mouse.x, mouse.y)
            editor.selected(tile.rect.name)
          }
          onPositionChanged: function(mouse) {
            if (!pressed) return
            const point = mapToItem(layoutMap, mouse.x, mouse.y)
            tile.dx = point.x - start.x
            tile.dy = point.y - start.y
          }
          onReleased: {
            const x = tile.rect.x + tile.dx / layoutMap.ratio
            const y = tile.rect.y + tile.dy / layoutMap.ratio
            const moved = Math.abs(tile.dx) + Math.abs(tile.dy) > 4
            tile.dx = 0
            tile.dy = 0
            if (!moved) return
            const layout = Model.dropDisplay(editor.rects, tile.rect.name, x, y, 8 / layoutMap.ratio)
            if (layout) editor.applyRules(layout.map(Model.layoutRule))
          }
          onCanceled: { tile.dx = 0; tile.dy = 0 }
        }
      }
    }
  }

  DisplayText {
    width: parent.width
    visible: editor.failed
    wrapMode: Text.WordWrap
    text: strings.t("display.failed")
  }

  component DisplayText: Text {
    textFormat: Text.PlainText
    color: Commons.Color.foreground
    font.family: Commons.Style.font.family
    font.pixelSize: Commons.Style.font.body
  }

  component DisplayCombo: Controls.ComboBox {
    id: combo
    property string label
    Accessible.name: label
    contentItem: DisplayText {
      text: combo.displayText
      leftPadding: combo.leftPadding
      rightPadding: combo.rightPadding + combo.indicator.width + combo.spacing
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
    }
    delegate: Controls.ItemDelegate {
      id: option
      required property int index
      required property string modelData
      width: ListView.view.width
      highlighted: index === combo.highlightedIndex
      contentItem: DisplayText {
        text: option.modelData
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
      }
    }
  }
}
