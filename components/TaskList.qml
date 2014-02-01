/*
 * Planner - A simple weekly planner
 * Copyright (C) 2014 Michael Spencer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import "../qml-air"
import "../qml-air/ListItems" as ListItem
import "../qml-air/dateutils.js" as DateUtils
import "../qml-air/listutils.js" as ListUtils

Widget {
    id: list
    property string title: date ? DateUtils.dayOfWeek(date) : "Unassigned"
    property var date
    property bool isToday: date ? DateUtils.isToday(date) : false
    property bool isPast: date ? DateUtils.dateIsBefore(date, DateUtils.today) : false
    property bool isComplete: ListUtils.filteredCount(model, function(item) { return !item.done }) === 0
    property int modelIndex

    property bool inline

    property var model: tasks[modelIndex]

    clip: true
    color: "transparent"
    style: inline ? "default" : isToday ? "primary"
                                        : isPast ? isComplete ? "success"
                                                              : "danger"
                                                 : "default"

    Label {
        id: titleLabel
        fontSize: "large"
        text: list.title
        elide: Text.ElideRight
        color: isToday ? theme.primary : theme.textColor
        font.bold: isToday
        visible: !inline
        height: visible ? implicitHeight : 0

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    Label {
        id: dateLabel
        anchors {
            right: parent.right
            bottom: titleLabel.bottom
        }
        fontSize: units.gu(1.4)
        text: Qt.formatDate(list.date)
        visible: titleLabel.visible
    }

    BackgroundView {
        id: background
        anchors {
            left: parent.left
            right: parent.right
            top: titleLabel.bottom
            bottom: parent.bottom
            topMargin: inline ? 0 : units.gu(1)
        }
        visible: !inline
        style: list.style
    }

    ListView {
        id: listView
        clip: true
        anchors {
            left: parent.left
            right: parent.right
            top: titleLabel.bottom
            bottom: divider.bottom
            topMargin: inline ? 0 : units.gu(1)
        }

        model: list.model
        delegate: TaskListItem {
            model: modelData
            itemIndex: index
        }

        opacity: isComplete && isPast && !list.mouseOver && !textField.editing ? 0.1 : 1

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Rectangle {
            id: landingBar
            color: theme.primary
            height:2
            width: parent.width
            visible: index != -1
            y: units.gu(3) * index
            property int index: -1
        }
    }

    ScrollBar {
        flickableItem: listView
    }

    Label {
        anchors.centerIn: listView
        fontSize: units.gu(1.9)
        text: "Nothing to do!"
        opacity: listView.count === 0 && !(isComplete && isPast) ? 0.5 : 0
    }

    Column {
        anchors.centerIn: background

        opacity: isComplete && isPast && !list.mouseOver && !textField.editing ? 1 : 0

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            size: units.gu(4)
            name: "check-circle"
            color: theme.success

            // Adds a white background to the check in the icon
            Rectangle {
                anchors.centerIn: parent
                width: units.gu(3)
                height: units.gu(3)
                radius: height/2
                z:-1
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            fontSize: "large"
            text: "All done!"
            color: theme.success
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Rectangle {
        id: divider
        anchors {
            left: parent.left
            right: parent.right
            bottom: textField.top
        }
        color: background.border.color
        visible: textField.anchors.bottomMargin != -textField.height
        height: 1
    }

    TextField {
        id: textField
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: enabled ? 1 : -height
            margins: 1

            Behavior on bottomMargin {
                NumberAnimation { duration: 200 }
            }
        }

        color: "white"
        radius: 0

        placeholderText: "Add task..."
        enabled: !isPast
        hidden: true

        onTriggered: {
            var globalList = tasks
            var list = model
            list.push({done: false, text: textField.text})
            globalList[modelIndex] = list
            tasks = globalList

            textField.text = ""
        }
    }

    function formatText(text) {
        var regex = /(\d\d?:\d\d\s*(PM|AM|pm|am))/gi
        text = text.replace(regex, "<font color=\"" + theme.success + "\">$1</font>")
        return text
    }

    ActionPopover {
        id: itemMenu

        property int index

        actions: [
            Action {
                name: "Edit"
                onTriggered: {
                    taskPopover.index = itemMenu.index
                    taskPopover.open(itemMenu.caller)
                }
            },

            Action {
                name: "Delete"
                style: "danger"
                onTriggered: {
                    var globalList = tasks
                    var list = model
                    print(itemMenu.index)
                    list.splice(itemMenu.index, 1)
                    globalList[modelIndex] = list
                    tasks = globalList
                }
            }

        ]
    }

    Popover {
        id: taskPopover
        width: row.implicitWidth + row.anchors.margins * 2 + units.gu(0.2)
        height: row.implicitHeight + row.anchors.margins * 2 + units.gu(0.2)
        property int index: -1

        onOpened: {
            editField.forceActiveFocus()
            editField.text = Qt.binding(function() { return  model[taskPopover.index] === undefined ? "" : model[taskPopover.index].text })
        }

        Row {
            id: row
            anchors.fill: parent
            anchors.margins: units.gu(1)
            spacing: units.gu(1)
            TextField {
                id: editField
                onTriggered: {
                    taskPopover.close()
                    var globalList = tasks
                    globalList[modelIndex][taskPopover.index].text = editField.text
                    tasks = globalList
                }
            }
            Button {
                text: "Done"
                onClicked: editField.triggered()
            }
        }

        Keys.onEscapePressed: taskPopover.close()
    }
}
