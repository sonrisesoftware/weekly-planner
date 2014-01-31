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
import "qml-air/listutils.js" as ListUtils
import "qml-air/ListItems" as ListItem

PageApplication {
    id: app
    title: "Weekly Planner"

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

        property var selectedDate: {
            var date = new Date()
            DateUtils.setDayOfWeek(date, selectedDay)
            return date
        }

        property int selectedDay: DateUtils.dayOfWeekIndex(new Date())

        property bool isToday: DateUtils.isToday(selectedDate)

        title: fullSize ? Qt.formatDate(weekStart) + " - " + Qt.formatDate(weekEnd)
                        : isToday ? app.width > units.gu(40) ? "Today - " + DateUtils.dayOfWeek(selectedDate) : "Today"
                                  : DateUtils.dayOfWeek(selectedDate)

        rightWidgets: [
            Button {
                iconName: theme.iconSettings
                onClicked: menu.open(caller)
            }
        ]

        drawer: Drawer {
            visible: !fullSize

            Column {
                anchors.fill: parent
                Repeater {
                    model: 8
                    delegate: ListItem.Standard {
                        height: units.gu(4)
                        fontSize: "medium"
                        selected: weekPage.selectedDay === index
                        onClicked: {
                            weekPage.drawer.close()
                            weekPage.selectedDay = index
                        }
                        style:  {
                            var date = new Date()
                            DateUtils.setDayOfWeek(date, index)
                            if (DateUtils.isToday(date))
                                return "primary"
                            else
                                return "default"
                        }

                        text: {
                            if (index < 7) {
                                var date = new Date()
                                DateUtils.setDayOfWeek(date, index)
                                return DateUtils.dayOfWeek(date)
                            } else {
                                return "Uncategoried"
                            }
                        }
                    }
                }
            }
        }

        TaskList {
            modelIndex: weekPage.selectedDay
            date: weekPage.selectedDate

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
            },

            Action {
                name: "About"
                onTriggered: aboutSheet.open()
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
                    deleteSheet.close()
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

    AboutSheet {
        id: aboutSheet

        icon: Qt.resolvedUrl("planner.png")
        name: "Weekly Planner"
        version: "0.1"
        copyright: "Copyright (C) 2014 Michael Spencer"
        license: "GPLv3"
        website: "http://github.com/iBeliever/weekly-planner"
        reportABug: "https://github.com/iBeliever/weekly-planner/issues/new"
    }

    Document {
        id: storage
        name: "planner"
        description: "Planner"

        Component.onCompleted: {
            if (storage.has("tasks"))
                tasks = JSON.parse(storage.get("tasks"))

            if (storage.has("weekStart") && !DateUtils.datesEqual(weekStart, new Date(storage.get("weekStart")))) {
                var incompleteTasks = []
                for (var i = 0; i < tasks.length; i++) {
                    incompleteTasks = incompleteTasks.concat(ListUtils.filter(tasks[i], function(item) { return !item.done }))
                }
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
                list[7] = incompleteTasks
                tasks = list
            }
        }

        Component.onDestruction: save()

        function save() {
            if (storage.cache) {
                storage.set("weekStart", weekStart.toJSON())
                storage.set("tasks", JSON.stringify(tasks))
            }
        }
    }
}

