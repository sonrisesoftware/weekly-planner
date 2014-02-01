import QtQuick 2.0
import "../qml-air"
import "../qml-air/ListItems" as ListItem
import "../qml-air/listutils.js" as ListUtils

ListItem.BaseListItem {
    id: listItem

    property var model
    property var itemIndex
    property bool trimmed: label.implicitWidth > label.width
    style: !isComplete && isPast && !modelData.done ? "danger" : "default"

    color: selected ? background_selected
                    : mouseOver ? background_mouseOver : dragArea.held ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,0)

    toolTip: trimmed ? model.text : ""

    onRightClicked: {
        itemMenu.index = itemIndex
        itemMenu.open(caller)
    }

    MouseArea {
         id: dragArea
         anchors.fill: parent
         property int positionStarted: 0
         property int positionEnded: listItem.y + listItem.height/2
         property int positionsMoved: Math.floor((positionEnded - positionStarted)/listItem.height)
         property int newPosition: index + positionsMoved
         property bool held: false
         drag.axis: Drag.YAxis

         onNewPositionChanged: {
             if (held) {
                 if (index === listView.count - 1)
                    landingBar.index = Math.min(newPosition, listView.count - 1)
                 else
                     landingBar.index = Math.min(newPosition, listView.count)
             }
         }

         onClicked: {
             taskPopover.index = index
             taskPopover.open(listItem)
         }

         onPressAndHold: {
             print("ON PRESS AND OLD")
             landingBar.index = index
              listItem.z = 2
              positionStarted = listItem.y
              dragArea.drag.target = listItem
              //listItem.opacity = 0.5
              listView.interactive = false
              held = true
              drag.maximumY = (taskList.height - listItem.height - 1 + listItem.contentY)
              drag.minimumY = 0
         }

         onReleased: {
             landingBar.index = -1
             print("RELEASED", positionsMoved)
              if ((Math.abs(positionsMoved) < 1 || newPosition >= listView.count) && held == true) {
                  held = false
                  print("Reseting to original position")
                   listItem.y = positionStarted
                   //listItem.opacity = 1
                   listView.interactive = true
                   dragArea.drag.target = null
              } else {
                   if (held == true) {
                       held = false
                       var list = tasks[modelIndex]
                        if (newPosition < 1) {
                             listItem.z = 1
                             list.move(index,0,1)
                             listItem.opacity = 1
                             listView.interactive = true
                             dragArea.drag.target = null
                        } else if (newPosition > listView.count - 1) {
                             listItem.z = 1
                             list.move(index,listView.count - 1,1)
                             listItem.opacity = 1
                             listView.interactive = true
                             dragArea.drag.target = null
                        } else {
                             listItem.z = 1
                             list.move(index,newPosition,1)
                             listItem.opacity = 1
                             listView.interactive = true
                             dragArea.drag.target = null
                        }
                        var tasksList = tasks
                        tasksList[modelIndex] = list
                        tasks = tasksList
                   }
              }
         }
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
            leftMargin: margins + (model.done ? -1 : 0)
            rightMargin: margins
        }
    }

    opacity: dragArea.held ? 0.5 : 1

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
}
