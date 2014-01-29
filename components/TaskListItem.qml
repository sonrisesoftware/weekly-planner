import QtQuick 2.0
import "../qml-air"
import "../qml-air/ListItems" as ListItem

ListItem.BaseListItem {
    id: listItem

    property var model
    property var itemIndex
    property bool trimmed: label.implicitWidth > label.width
    style: !isComplete && isPast && !modelData.done ? "danger" : "default"

    toolTip: trimmed ? model.text : ""

    onRightClicked: {
        itemMenu.index = itemIndex
        itemMenu.open(caller)
    }

    Icon {
        id: icon

        width: height
        name: model.done ? "check-square-o" : "square-o"
        size: listItem.fontSize
        color: textColor

        mouseEnabled: true
        onClicked: {
            var list = tasks
            model.done = !model.done
            list[modelIndex][itemIndex] = model
            tasks = list
        }

        anchors {
            left: parent.left
            leftMargin: margins + (model.done ? 1 : 0)
            verticalCenter: parent.verticalCenter
        }
    }

    Label {
        id: label

        style: listItem.style
        color: textColor
        elide: Text.ElideRight
        text: formatText(model.text)

        anchors {
            verticalCenter: parent.verticalCenter
            left: icon.right
            right: parent.right
            margins: margins + (model.done ? -1 : 0)
        }
    }
}
