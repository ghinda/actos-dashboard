import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as Plasma
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.qtextracomponents 0.1 as QtExtra

Item {
	id: dashboard
	width: 500
	height: 300
	property int screenWidth: 0
	property int screenHeight: 0
	property int dashHeight: 0
    
	property int launcherWidth: 130
	property int dockHeight: 50
	
	property int previousIndex : 0
	
	property string searchQuery : ''
	property int mininumStringLength : 3
	
	property int runningActivities : 0
	property string currentActivity : ''
	property variant stateSource
	
	// category button component
	Component {
		id: dashboardCategoryButton
		
		Image {
			id: dashboardCategoryImage
			fillMode: Image.PreserveAspectFit
			source: "../images/" + icon
			width: 64
			height: 64
			opacity: 0.3
			anchors.horizontalCenter: parent.horizontalCenter
			
			states: [
				State {
					name: "active"
					when: dashboardCategories.currentIndex == index
					
					PropertyChanges {
						target: dashboardCategoryImage
						opacity: 1
					}
					
					PropertyChanges {
						target: views.children[index]
						opacity: 1
					}
				},
				
				State {
					name: "hover"
					PropertyChanges {
						target: dashboardCategoryImage
						opacity: 0.5
					}
				},
				
				State {
					name: "hide"
					PropertyChanges {
						target: dashboardCategoryImage
						opacity: 0
					}
				}
			]
			
			transitions: Transition {
				PropertyAnimation { property: "opacity"; duration: 100 }
			}
			
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				
				onEntered: {
					if(parent.state != "active") parent.state = "hover"
				}
				
				onExited: {
					if(parent.state != "active") parent.state = ""
				}
				
				onClicked: {
					// activate button
					dashboardCategories.currentIndex = index;
				}
			}
			
			Component.onCompleted: {
				if(icon == "searchIcon.png") {
					dashboardCategoryImage.state = "hide";
				}
			}
			
		}
		
	}
	
	// categories model
	ListModel {
		id: dashboardCategoriesModel
		
		ListElement {
			icon: "windowsIcon.png"
		}
		
		ListElement {
			icon: "applicationsIcon.png"
		}
		
		ListElement {
			icon: "activitiesIcon.png"
		}
		
		ListElement {
			icon: "searchIcon.png"
		}

	}

	// dashboard views
	Item {
		id: viewsContainer
		width: screenWidth
		height: dashHeight
		focus: true
		anchors.rightMargin: 20
		
		PlasmaWidgets.LineEdit {
			id: searchField
			text: ""
			width: 190
			z: 9
			anchors {
				top: parent.top
				topMargin: 20
				right: parent.right
				rightMargin: 20
			}
			
			onTextChanged: {
				
				if(text.length >= mininumStringLength) {
				
					// set search query
					searchQuery = text.toLowerCase();
					
					// activate search view
					dashboardCategories.currentIndex = 3;
					
					// search - activities
					searchView.search();
					
				} else {
					
					// activate windows
					dashboardCategories.currentIndex = previousIndex;
					
					// hide search button
					dashboardCategories.contentItem.children[4].state = "hide";
					
				};
				
			}
			
		}
		
		Keys.onPressed: {
			if(event.key == Qt.Key_Backspace) {
				// delete last char
				searchField.text = searchField.text.substring(0, searchField.text.length - 1);
			} else if(event.key == Qt.Key_Down) {
				// focus app results
				searchView.appResultsGrid.focus = true;
			} else if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
			
				// if appresultgrid not focused, run first app
				if(!searchView.appResultsGrid.focus && searchField.text) {
					// run first app result
					searchView.runApp(0, 0);
				}
				
			} else {
				// add text to textfield
				searchField.text += event.text;
			}
			
		}
		
		// dashboard categories
		Item {
			id: dashboardCategoriesContainer
			width: launcherWidth
			anchors {
				top: parent.top
				left: parent.left
				bottom: parent.bottom
			}
			
			ListView {
				id: dashboardCategories
				width: parent.width
				height: 320
				spacing: 20
				interactive: false
				anchors {
					left: parent.left
					leftMargin: 3
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				currentIndex: 0
				
				model: dashboardCategoriesModel
				delegate: dashboardCategoryButton
				
				highlight: Rectangle {
					width: 3
					opacity: 0.8
					color: "white"
				}

			}
		
		}
		
		Item {
			id: views
			
			anchors {
				top: searchField.bottom
				topMargin: 50
				left: dashboardCategoriesContainer.right
				leftMargin: 50
				right: parent.right
				rightMargin: 30
				bottom: parent.bottom
			}
			
			WindowSwitcher {
				id: windowsView
				opacity: 0
				visible: (windowsView.opacity) ? true : false
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: windowsView
						opacity: 1
					}
				}

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
				
			}
			
			Applications {
				id: applicationsView
				opacity: 0
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: applicationsView
						opacity: 1
					}
				}

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
			
			Activities {
				id: activitiesView
				opacity: 0
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: activitiesView
						opacity: 1
					}
				}

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
			
			Search {
				id: searchView
				opacity: 0

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
		}
	}
	
	// dashboard content
	PlasmaCore.Dialog {
        id: dashboardContent
        x: 0
        windowFlags: Qt.Popup
        visible: false
        
        mainItem: viewsContainer
	}
	
	// dashboard button
	PlasmaCore.Dialog {
        id: dashboardButton
        x: 0
        y: 0
        windowFlags: Qt.X11BypassWindowManagerHint
        
        mainItem: dashboardButttonContainer
	}
	
	Item {
		id: dashboardButttonContainer
		width: 28
		height: 20
		
		Plasma.ToolButton {
			anchors.fill: parent
			
			onClicked: toggleBoth()
			
			Image {
				id: dashboardIcon
				width: 15
				height: 15
				source: "../images/dashboardIcon.png"
				
				anchors {
					left: parent.left
					leftMargin: 5
				}
				
				opacity: (dashboardContent.visible) ? 1 : 0.5
				
				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
				}
			}
		}
	}
    
    Timer {
		id: removeCashew
		repeat: false
		interval: 200
		triggeredOnStart: false
		onTriggered: {
			
			var cashewRemoveScript = '#!/bin/sh\n\
js=$(mktemp)\n\
cat > $js <<_EOF\n\
var activity = new Activity("desktop");\n\
activity.addWidget("py-cashew");\n\
_EOF\n\
qdbus org.kde.plasma-desktop /App local.PlasmaApp.loadScriptInInteractiveConsole "$js" > /dev/null\n\
xdotool search --name "Desktop Shell Scripting Console – Plasma Desktop Shell" windowactivate key ctrl+e key ctrl+w\n\
rm -f "$js"\n\
#' + new Date().getTime();
			
			// remove the cashew
			executableSource.connectSource(cashewRemoveScript);
			
		}
	}
    
	// activities source
	PlasmaCore.DataSource {
		id: activitiesSource
		dataEngine: "org.kde.activities"

		onSourceAdded: {
			connectSource(source);
			runningActivities++;
			
			// add to model
			var sourceData = activitiesSource.data[source];
			sourceData.DataEngineSource = source;
			
			activitiesModel.insert(activitiesModel.count - 1, sourceData);
			
			// set current
			var currentOperation = activitiesSource.serviceForSource(source).operationDescription('setCurrent');
			activitiesSource.serviceForSource(source).startOperationCall(currentOperation);
			
			// remove cashew
			removeCashew.start();
			
			// set previous to false
			for(var i = 0; i < activitiesModel.count; i++) {
				if(activitiesModel.get(i).Current == true) {
					activitiesModel.setProperty(i, "Current", false);
				}
			}
			
			// set current to true
			activitiesModel.setProperty(activitiesModel.count - 2, "Current", true);
			
		}
		
		onSourceRemoved: {
			disconnectSource(source);
			runningActivities--;
			
			// remove from model
			for(var i = 0; i < activitiesModel.count; i++) {
				if(source == activitiesModel.get(i).DataEngineSource) {
					activitiesModel.remove(i);
				}
			}
		}
		
		Component.onCompleted: {
			stateSource = sources[sources.length - 1];
			connectedSources = sources;
			
			runningActivities = activitiesSource.data[stateSource].Running.length;
			
			for(var i=0; i < sources.length; i++) {
				var sourceData = activitiesSource.data[sources[i]];
				sourceData.DataEngineSource = sources[i];
				
				activitiesModel.append(sourceData);
			}
			
			// connect signal after connecting sources
			activitiesSource.dataChanged.connect(function() {
				
				runningActivities = activitiesSource.data[stateSource].Running.length;
				
				// get new wallpapers
				for(var i=0; i < activitiesModel.count; i++) {
					
					for(var j=0; j < activitiesSource.connectedSources.length; j++) {
					
						if(activitiesModel.get(i).DataEngineSource == activitiesSource.connectedSources[j]) {
							
							activitiesModel.get(i).Icon = activitiesSource.data[activitiesSource.connectedSources[j]].Icon;
							
						}
						
					}
					
				}
				
				if(currentActivity != activitiesSource.data[stateSource].Current) {
					currentActivity = activitiesSource.data[stateSource].Current;
					
					// get new windows for activity
					
					// when changed activity, get new windows
					windowThumbs.clear();
					
					// add new clients to model
					var clients = workspace.clientList();
					
					var i = 0;
					for (i = 0; i < clients.length; i++) {
						
						if(visibleClient(clients[i])) {
							
							// match activity
							if(clients[i].activities == "" || clients[i].activities == currentActivity) {
								
								windowThumbs.append({
									"windowId": clients[i].windowId,
									"gridId": windowThumbs.count,
									"client": clients[i]
								});
							
							};
							
						}
						
					}
					
					// recalculate thumb size
					windowsView.recalculateCellSize();
				}
				
			})
			
		}
	}
	
	PlasmaCore.DataSource {
		id: executableSource
		dataEngine: "executable"
	}
	
	ListModel {
		id: windowThumbs
	}
	
	ListModel {
		id: activitiesModel
	}
	
	/*
	PlasmaCore.DataModel {
		id: activitiesModel
		dataSource: activitiesSource
    }
    */
	
	// toggle complete dashboard
	function toggleBoth() {
		
		if(dashboardContent.visible == true) {

			dashboardContent.visible = false;
			
			workspace.slotToggleShowDesktop();
			
		} else {
			
			// clear search field
			searchField.text = "";
			// show content
			dashboardContent.visible = true;
			
			if(windowThumbs.count) {
				dashboardCategories.currentIndex = 0;
			} else {
				dashboardCategories.currentIndex = 1;
			}
			
			// Activate Window and text field
			dashboardContent.activateWindow();
			
			// Activate Window and text field
			viewsContainer.forceActiveFocus();
			
			// check if there are any normalWindows active/everything is not minimized already
			if(workspace.activeClient && workspace.activeClient.normalWindow) {
				// show desktop - minimize everything
				workspace.slotToggleShowDesktop();
			}
		}
	
	}
	
	// check if the client/window should be visible in the windowSwitcher
    function visibleClient(client) {
		if(client.dock || client.skipSwitcher || client.skipTaskbar || !client.normalWindow) {
			return false;
		} else {
			return true;
		}
	}
	
	Component.onCompleted: {

		var screen = workspace.clientArea(KWin.MaximizedArea, workspace.activeScreen, workspace.currentDesktop);
        screenWidth = screen.width;
        screenHeight = screen.height;
		
		dashHeight = screenHeight - dockHeight;
		
		dashboardContent.y = 22;
		dashboardContent.x = 0;
		dashboardContent.visible = false;
	
		dashboardButton.visible = true;
		
		// register top-left screen edge
		registerScreenEdge(KWin.ElectricTopLeft, function() {
			toggleBoth();
		});
		
		// register dashboard shortcut
		registerShortcut("Activate Actos Dashboard", "", "Meta+A", function() {
			toggleBoth();
		});
    }
    
}