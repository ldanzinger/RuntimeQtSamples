/*
Copyright 2015 Esri.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import QtQuick 2.3
import QtQuick.Controls 1.2
import ArcGIS.Runtime 10.26
import ArcGIS.Extras 1.0

ApplicationWindow {
    id: appWindow
    width: 1250
    height: 790
    title: "MapsAndCharts"

    property real pop2012
    property real pop2010
    property real totalCrime
    property real scaleFactor: System.displayScaleFactor
    property var barChartData
    property var pieChartData

    Component.onCompleted: {
        ArcGISRuntime.doPost = true;
    }

    Map {
        id: map
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width: appWindow.width * .50
        extent: soCalExtent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer"
        }

        ArcGISDynamicMapServiceLayer {
            id: demoDynamicMapService
            url: "http://services.arcgisonline.com/arcgis/rest/services/Demographics/USA_Median_Household_Income/MapServer"
            opacity: 0.8
            onStatusChanged: {
                if (status === Enums.LayerStatusInitialized) {
                    var legendItems = legend[0].legendItems;
                    legendView.legendImage0 = legendItems[0].image;
                    legendView.legendLabel0 = legendItems[0].label;
                    legendView.legendImage1 = legendItems[1].image;
                    legendView.legendLabel1 = legendItems[1].label;
                    legendView.legendImage2 = legendItems[2].image;
                    legendView.legendLabel2 = legendItems[2].label;
                    legendView.legendImage3 = legendItems[3].image;
                    legendView.legendLabel3 = legendItems[3].label;
                    legendView.legendImage4 = legendItems[4].image;
                    legendView.legendLabel4 = legendItems[4].label;
                    legendView.legendImage5 = legendItems[5].image;
                    legendView.legendLabel5 = legendItems[5].label;
                    legendView.legendImage6 = legendItems[6].image;
                    legendView.legendLabel6 = legendItems[6].label;
                }
            }
        }

        FeatureLayer {
            featureTable: gdbLaCounty
        }

        GeodatabaseFeatureServiceTable {
            id: gdbLaCounty
            url: "https://services1.arcgis.com/e7dVfn25KpfE6dDd/arcgis/rest/services/LACrimeAndDemo/FeatureServer/1"
        }

        GraphicsLayer {
            id: gl
            opacity: 0.7
        }

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Reference/MapServer"
        }

        QueryTask {
            id: demoQueryTask
            url: "https://services1.arcgis.com/e7dVfn25KpfE6dDd/arcgis/rest/services/LACrimeAndDemo/FeatureServer/0"

            onQueryTaskStatusChanged: {
                if (queryTaskStatus === Enums.QueryTaskStatusErrored) {
                    console.log("query task error");
                } else if (queryTaskStatus === Enums.QueryTaskStatusCompleted) {
                    for (var i = 0; i < queryResult.graphics.length; ++i) {
                        var attributes = queryResult.graphics[0].attributes;
                        pop2012 = attributes["TotalPop2012"];
                        pop2010 = attributes["TotalPop2010"];

                        barChartData = {
                                    labels: ["Arson","Rape","Grand Theft","Theft","Homicide","Robbery","Burglary", "Assault"],
                                    datasets: [{
                                            fillColor: "rgba(0, 115, 153, 0.5)",
                                            strokeColor: "rgba(0, 115, 153, 1)",
                                            data: [attributes["SumArson"],
                                                   attributes["SumRape"],
                                                   attributes["SumGrandTheft"],
                                                   attributes["SumCriminalHomicide"],
                                                   attributes["SumRobbery"],
                                                   attributes["SumBurglary"],
                                                   attributes["SumAssault"],
                                                   attributes["SumTotalCrime"]]
                                    }]
                        };

                        pieChartData = [{
                                            value: attributes["TotalOwnerOcc"],
                                            color: "#4daf4a"
                                        },
                                        {
                                            value: attributes["TotalRenterOcc"],
                                            color: "#e41a1c"
                                        },
                                        {
                                            value: attributes["TotalVacant"],
                                            color: "#377eb8"
                                        }];

                        infoGraphic.dataUpdated();
                    }
                }
            }
        }

        Query {
            id: demoQuery
            where: "1=1"
            spatialRelationship: Enums.SpatialRelationshipIntersects
            outSpatialReference: map.spatialReference
            outStatistics: [
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "POP2012"
                    outStatisticFieldName: "TotalPop2012"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "POP2010"
                    outStatisticFieldName: "TotalPop2010"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "OWNER_OCC"
                    outStatisticFieldName: "TotalOwnerOcc"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "RENTER_OCC"
                    outStatisticFieldName: "TotalRenterOcc"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "VACANT"
                    outStatisticFieldName: "TotalVacant"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Total_Crime"
                    outStatisticFieldName: "SumTotalCrime"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Theft"
                    outStatisticFieldName: "SumTheft"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Grand_Theft"
                    outStatisticFieldName: "SumGrandTheft"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Burglary"
                    outStatisticFieldName: "SumBurglary"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Arson"
                    outStatisticFieldName: "SumArson"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Rape"
                    outStatisticFieldName: "SumRape"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Robbery"
                    outStatisticFieldName: "SumRobbery"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Criminal_Homicide"
                    outStatisticFieldName: "SumCriminalHomicide"
                },
                OutStatistics {
                    statisticsType: Enums.StatisticsTypeSum
                    onStatisticField: "Sum_Assault"
                    outStatisticFieldName: "SumAssault"
                }
            ]
        }

        Envelope {
            id: soCalExtent
            spatialReference: map.spatialReference
            xMax: -13138649.383229068
            xMin: -13177785.127230378
            yMax: 4047773.105206928
            yMin: 4006265.4979328117
        }

        onMouseClicked: {
            // create the buffer
            gl.removeAllGraphics();
            var pt = mouse.mapPoint;
            var graphic = ArcGISRuntime.createObject("Graphic");
            var buffer = pt.buffer(5, mile);
            graphic.geometry = buffer;
            graphic.symbol = baseSFS;
            gl.addGraphic(graphic);

            // query features within the buffer
            demoQuery.geometry = buffer;
            demoQueryTask.execute(demoQuery)
        }

        LinearUnit {
            id: mile
            wkid: Enums.LinearUnitCodeMileUS
        }

        SimpleFillSymbol {
            id: baseSFS
            color: "lightgrey"
            outline: SimpleLineSymbol {
                color: "black"
                width: 4
            }
        }
    }

    Rectangle {
        id: titleBar
        color: "transparent"
        anchors {
            left: map.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 75 * scaleFactor

        border {
            color: "black"
            width: 2
        }

        Column {
            anchors.centerIn: parent
            rotation: 270

            Text {
                id: title
                text: "Los Angeles Data Explorer"
                font {
                    bold: true
                    capitalization: Font.AllUppercase
                    family: "sanserif"
                    pointSize: 35
                }
            }

            Text {
                text: "A crime and demographic data exploration tool"
                font {
                    family: "sanserif"
                    pointSize: 12
                }
            }
        }

    }

    Infographic {
        id: infoGraphic
        anchors {
            left: titleBar.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: 15 * scaleFactor
        }
    }

    Legend {
        id: legendView
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 15 * scaleFactor
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 2 * scaleFactor
            color: "black"
        }
    }
}

