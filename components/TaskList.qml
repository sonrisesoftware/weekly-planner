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
    property string title: date ? DateUtils.dayOfWeek(date) : "Backlog"
    property var date
    property bool isToday: date ? DateUtils.isToday(date) : false
    property bool isPast: date ? DateUtils.dateIsBefore(date, DateUtils.today) : false
    property bool isComplete: ListUtils.filteredCount(model, function(item) { return !item.done }) === 0
    property int modelIndex

    property var model: tasks[modelIndex]

    clip: true
    color: "transparent"

    Label {
        id: titleLabel
        fontSize: "large"
        text: list.title
        elide: Text.ElideRight
        color: isToday ? theme.primary : theme.textColor
        font.bold: isToday

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    BackgroundView {
        id: background
        anchors {
            left: parent.left
            right: parent.right
            top: titleLabel.bottom
            bottom: parent.bottom
            topMargin: units.gu(1)
        }
        style: isToday ? "primary"
                       : isPast ? isComplete ? "success"
                                             : "danger"
                                : "default"
    }

    ListView {
        id: listView
        anchors {
            left: parent.left
            right: parent.right
            top: titleLabel.bottom
            bottom: divider.bottom
            topMargin: units.gu(1)
        }

        model: list.model
        delegate: ListItem.Standard {
            text: modelData.text
            iconName: modelData.done ? "check-square-o" : "square-o"
            style: !isComplete && isPast && !modelData.done ? "danger" : "default"

            onClicked: {
                var list = tasks
                var item = modelData
                item.done = !item.done
                list[modelIndex][index] = item
                tasks = list
            }
        }

        opacity: isComplete && isPast && !list.mouseOver && !textField.editing ? 0.3 : 1

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
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
}
