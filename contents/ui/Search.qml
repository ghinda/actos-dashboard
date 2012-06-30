import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as Plasma
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.runnermodel 0.1 as RunnerModels

Item {
	anchors.fill: parent
	clip: true

	property int activitySearchIndex : 0
	
	property alias appResultsGrid : appResultsGrid
	property alias appsRunnerModel : appsRunnerModel
	
	/* UI */
	
	Component {
		id: appItem
		
		Item {
			width: 128
			height: 128
			
			PlasmaCore.FrameSvgItem {
				id: focusFrame
				imagePath: 'widgets/frame'
				prefix: 'plain'
				anchors.fill: parent
				
				visible: parent.GridView.isCurrentItem
			}
			
			PlasmaWidgets.IconWidget {
				id: resultIcon
				text: label
				preferredIconSize: "64x64"
				minimumIconSize: "64x64"
				drawBackground: false
				
				anchors {
					fill: parent
					margins: 10
				}
				
				onClicked: {
					runApp(runnerid, index);
				}
			}
			
			Keys.onPressed: {
				if ( event.key == Qt.Key_Enter || event.key == Qt.Key_Return ) {
					runApp(runnerid, index);
				}
			}
			
			Component.onCompleted: {
				
				// there's an issue with the icon returned from runnermodel
				// so we can't assign it directly to the iconwidget
				resultIcon.icon = icon;
				
			}
			
		}
	}
	
	Flickable {
		id: searchContainer
		anchors.fill: parent
		contentWidth: parent.width
		contentHeight: appSearchContainer.height + placesSearchContainer.height + recentSearchContainer.height + activitySearchContainer.height
	
		Item {
			id: appSearchContainer
			anchors {
				top: parent.top
				right: parent.right
				left: parent.left
			}
			height: appsRunnerModel.count ? childrenRect.height : 0
			visible: appsRunnerModel.count
			
			Plasma.Label {
				id: applicationsLabel
				text: 'Applications'
				anchors {
					top: parent.top
				}
			}

			GridView {
				id: appResultsGrid
				focus: true
				height: childrenRect.height
				anchors {
					top: applicationsLabel.bottom
					left: parent.left
					right: parent.right
				}
				flickableDirection: Flickable.HorizontalFlick
				
				model: appsRunnerModel
				
				cellWidth: 150
				cellHeight: 150
				delegate: appItem
				
				KeyNavigation.up: searchField
				KeyNavigation.down: (placesResultsGrid.visible) ? placesResultsGrid : placesResultsGrid.KeyNavigation.down
			}
			
		}
		
		Item {
			id: placesSearchContainer
			anchors {
				top: appSearchContainer.bottom
				topMargin: 20
				right: parent.right
				left: parent.left
			}
			height: placesRunnerModel.count ? childrenRect.height : 0
			visible: placesRunnerModel.count
			
			Plasma.Label {
				id: placesLabel
				text: 'Places'
				anchors {
					top: parent.top
				}
			}

			GridView {
				id: placesResultsGrid
				focus: true
				height: childrenRect.height
				anchors {
					top: placesLabel.bottom
					left: parent.left
					right: parent.right
				}
				flickableDirection: Flickable.HorizontalFlick
				
				model: placesRunnerModel
				
				cellWidth: 150
				cellHeight: 150
				delegate: appItem
				
				KeyNavigation.up: (appResultsGrid.visible) ? appResultsGrid : appResultsGrid.KeyNavigation.up
				KeyNavigation.down: (recentResultsGrid.visible) ? recentResultsGrid : recentResultsGrid.KeyNavigation.down
			}
		}
		
		Item {
			id: recentSearchContainer
			anchors {
				top: placesSearchContainer.bottom
				topMargin: 20
				right: parent.right
				left: parent.left
			}
			height: recentRunnerModel.count ? childrenRect.height : 0
			visible: recentRunnerModel.count
			
			Plasma.Label {
				id: recentLabel
				text: 'Recent'
				anchors {
					top: parent.top
				}
			}

			GridView {
				id: recentResultsGrid
				focus: true
				height: childrenRect.height
				anchors {
					top: recentLabel.bottom
					left: parent.left
					right: parent.right
				}
				flickableDirection: Flickable.HorizontalFlick
				
				model: recentRunnerModel
				
				cellWidth: 150
				cellHeight: 150
				delegate: appItem
				
				KeyNavigation.up: (placesResultsGrid.visible) ? placesResultsGrid : placesResultsGrid.KeyNavigation.up
				KeyNavigation.down: (activityResultsGrid.visible) ? activityResultsGrid : searchField
			}
		}		
		
		Item {
			id: activitySearchContainer
			anchors {
				top: recentSearchContainer.bottom
				topMargin: 20
				left: parent.left
				right: parent.right
			}
			height: activityResultsModel.count ? childrenRect.height : 0
			visible: activityResultsModel.count
		
			Plasma.Label {
				id: activityLabel
				text: 'Activities'
				anchors {
					top: parent.top
				}
			}
				
			GridView {
				id: activityResultsGrid
				focus: true
				height: childrenRect.height
				anchors {
					top: activityLabel.bottom
					left: parent.left
					right: parent.right
				}
				flickableDirection: Flickable.HorizontalFlick
				
				model: activityResultsModel
				
				cellWidth: 150
				cellHeight: 150
				delegate: ActivityItem {}
				
				KeyNavigation.up: (recentResultsGrid.visible) ? recentResultsGrid : recentResultsGrid.KeyNavigation.up
				KeyNavigation.down: searchField
			}
		}
		
	}
	
	Plasma.ScrollBar {
		anchors {
			top: searchContainer.top
			right: searchContainer.right
			bottom: searchContainer.bottom
		}
		flickableItem: searchContainer
	}
	
	Plasma.Label {
		id: noResultsLabel
		text: 'Sorry, there is nothing that matches your search'
		anchors.fill: parent
		visible: !activityResultsModel.count && !recentRunnerModel.count && !placesRunnerModel.count && !appsRunnerModel.count
	}
	
	
	/* Search Functionality and Models */
	
	RunnerModels.RunnerModel {
		id: appsRunnerModel
		runners: [ "services", "kill", "kget", "calculator" ]
		query: searchQuery
	}
	
	RunnerModels.RunnerModel {
		id: placesRunnerModel
		runners: [ "sessions", "places", "solid" ]
		query: searchQuery
	}
	
	RunnerModels.RunnerModel {
		id: recentRunnerModel
		runners: [ "recentdocuments" ]
		query: searchQuery
	}
	
	/* Activities Search */
	ListModel {
		id: activityResultsModel
	}
	
	// Search "Thread"
	Timer {
		id: searchActivityTimer
		repeat: true
		interval: 1
		triggeredOnStart: false
		onTriggered: {
			
			if(!searchActivities(searchQuery)) {
				stop();
			}
			
		}
	}
	
	function searchActivities(activityName) {
		
		if(activitiesModel.get(activitySearchIndex).Name && activitiesModel.get(activitySearchIndex).Name.toLowerCase().indexOf(activityName) != -1) {
			activityResultsModel.append(activitiesModel.get(activitySearchIndex));
			
			activitySearchContainer.opacity = 1;
		};
		
		activitySearchIndex++;
		
		if (activitySearchIndex == activitiesModel.count) return false;
		
		return true;
	}
	
	/* Global search method 
	 * - currently searches only activities
	 */
	function search(string) {
		// clear activities results
		searchActivityTimer.stop();
		activitySearchIndex = 0;
		activityResultsModel.clear();
		activitySearchContainer.opacity = 0;
		
		// search activities
		searchActivityTimer.start();
	}
	
	/* Run app */
	// TODO Find better fix for this, to know which runner to use for launching
	function runApp(runnerid, index) {
		
		// default to app runner
		var runner = appsRunnerModel;
		
		// places
		if([ "sessions", "places", "solid", "nepomuksearch" ].indexOf(runnerid) != -1) {
			runner = placesRunnerModel;
		}
		
		// recent
		if([ "recentdocuments" ].indexOf(runnerid) != -1) {
			runner = recentRunnerModel;
		}
		
		runner.run(index);
	}
	
	function runFirstApp(event) {
		// first runner with results
		var runner;
	
		if(appsRunnerModel.count) {
			runner = appsRunnerModel
		} else {
			if(placesRunnerModel.count) {
				runner = placesRunnerModel
			} else if(recentRunnerModel.count) {
				runner = recentRunnerModel
			} else if(activityResultsModel.count) {
				runner = activityResultsModel
			}
		}
		
		if(runner) {
			runner.run(0);
		}
	}
	
	Component.onCompleted: {
		
		// attach key events to the seachfield
		searchField.KeyNavigation.up = appResultsGrid
		searchField.KeyNavigation.down = appResultsGrid
		
		searchField.Keys.enterPressed.connect(runFirstApp);
		searchField.Keys.returnPressed.connect(runFirstApp);
		
	}
	
}