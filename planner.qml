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

    Page {
        id: weekPage

        title: "1/26/14 - 2/1/14"

        rightWidgets: [
            Button {
                iconName: "cog"
                onClicked: menu.open(caller)
            }
        ]

        Grid {
            id: grid
            anchors {
                fill: parent
                margins: units.gu(2)
            }

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
                onTriggered: {
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

        Component.onDestruction: {
            //storage.set("tasks", [])
            storage.set("tasks", JSON.stringify(tasks))
        }
    }
}
