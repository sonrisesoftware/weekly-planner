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
import "qml-air"
import "components"
import "qml-air/dateutils.js" as DateUtils

PageApplication {
    id: app
    title: "Planner"

    width: units.gu(110)
    height: units.gu(80)

    initialPage: weekPage

    property var weekStart: {
        var date = new Date()
        DateUtils.setDayOfWeek(date, 0)
        return date
    }

    property var weekEnd: {
        var date = new Date()
        DateUtils.setDayOfWeek(date, 6)
        return date
    }

    property var tasks: [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        []
    ]

    onTasksChanged: storage.save()

    navbarSize: fullSize ? "normal" : "small"
    property bool fullSize: width > units.gu(90) && height > units.gu(60)

    Page {
        id: weekPage

        title: fullSize ? Qt.formatDate(weekStart) + " - " + Qt.formatDate(weekEnd) : "Today"

        rightWidgets: [
            Button {
                iconName: "cog"
                onClicked: menu.open(caller)
            }
        ]

        TaskList {
            modelIndex: DateUtils.dayOfWeekIndex(date)
            date: new Date

            visible: !fullSize
            anchors.fill: parent
            inline: true
        }

        Grid {
            id: grid
            anchors {
                fill: parent
                margins: units.gu(2)
            }
            visible: fullSize

            columns: 4
            spacing: units.gu(2)

            Repeater {
                model: 8
                delegate: TaskList {
                    modelIndex: index
                    date: {
                        if (index < 7) {
                            var date = new Date()
                            DateUtils.setDayOfWeek(date, index)
                            return date
                        } else {
                            return undefined
                        }
                    }

                    width: (grid.width - units.gu(6))/4
                    height: (grid.height - units.gu(2))/2
                }
            }
        }
    }

    ActionPopover {
        id: menu

        actions: [
            Action {
                name: "Erase planner"
                style: "danger"
                onTriggered: deleteSheet.open()
            }

        ]
    }

    Sheet {
        id: deleteSheet

        title: "Erase Planner"
        style: "danger"

        Label {
            text: "Are you sure your want to erase the planner?"
        }

        footer: [
            Button {
                text: "Cancel"
                onClicked: deleteSheet.close()
            },

            Button {
                text: "Erase"
                style: "danger"
                onClicked: {
                    var list = [
                            [],
                            [],
                            [],
                            [],
                            [],
                            [],
                            [],
                            []
                        ]
                    tasks = list
                }
            }
        ]
    }

    Document {
        id: storage
        name: "planner"
        description: "Planner"

        Component.onCompleted: {
            if (storage.has("tasks"))
                tasks = JSON.parse(storage.get("tasks"))
        }

        Component.onDestruction: save()

        function save() {
            if (storage.cache)
                storage.set("tasks", JSON.stringify(tasks))
        }
    }
}

