import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Plasma
// import org.kde.plasma.graphicswidgets 2.0 as PlasmaWidgets

import "../code/apps.js" as Apps

Item {
	id: appsRoot
	anchors.fill: parent
	clip: true
	
	property string appSearchQuery : '/'
	property int i : 0
	property int categoryIndex : 0
	
	property variant sources
	property variant entry

	function getMenuItems(source) {
		if(!sources) sources = appsSource.data[appSearchQuery]["entries"];
		entry = appsSource.data[sources[i]];
		
		if (sources[i] != "---" && entry && entry["name"]) {
			
			if (Apps.appNames.indexOf(entry["name"]) < 0 && entry["name"] != ".hidden") {
				
				Apps.appNames.push(entry["name"]);
				
				if (entry["isApp"] && entry["display"]) {
					
					var app = {
						source: sources[i],
						name: entry["name"],
						genericName: entry["genericName"],
						menuId: entry["menuId"],
						iconName: entry["iconName"],
						entryPath: entry["entryPath"]
					};
					
					Apps.allApps.push(app);
					
					Apps.categories[Apps.categoryName].apps.push(app);
					
				} else if(entry["entries"] && entry["entries"].length > 0) {
					
					// check if major category
					// subcategories don't have name
					// check number of / in name
					
					if(entry["name"] && sources[i].split('/').length == 2) {
						
						Apps.categoryNames.push({
							source: sources[i],
							name: entry["name"],
							genericName: entry["genericName"],
							iconName: entry["iconName"]
						});
						
						
						Apps.categories[entry["name"]] = {
							source: sources[i],
							genericName: entry["genericName"],
							iconName: entry["iconName"],
							entryPath: entry["entryPath"],
							menuId: entry["menuId"],
							apps: []
						};
					
					}
					
					appCategories.append({
						source: sources[i],
						name: entry["name"]
					});
				}
			
			}
			
		}
		
		if(i < sources.length - 1) {
			i++;
			return true;
		} else {
			
			i = 0;
			
			if(categoryIndex == appCategories.count) {
				Apps.allApps.sort(sortByName);
				appGrid.model = Apps.allApps;
				
				categoriesList.model = Apps.categoryNames;
				
				return false;
			}
			
			appSearchQuery = appCategories.get(categoryIndex).source;
			
			if( appCategories.get(categoryIndex).name && appSearchQuery.split('/').length == 2 ) {
				Apps.categoryName = appCategories.get(categoryIndex).name;
			}
			
			sources = appsSource.data[appSearchQuery]["entries"];
			
			categoryIndex++;
			return true;
		}
		
	}
	
	function sortByName(a, b) {
		var nameA = a.name.toLowerCase(),
			nameB = b.name.toLowerCase();
			
		if (nameA < nameB) //sort string ascending
			return -1 
		if (nameA > nameB)
			return 1
		
		return 0 //default return value (no sorting)
	}
	
	ListModel {
		id: appCategories
	}
	
	PlasmaCore.DataSource {
		id: appsSource
		dataEngine: "apps"

		onSourceAdded: {
			connectSource(source);
			
			appSearchQuery = source;
			categorizeAppsTimer.start();
		}
		
		Component.onCompleted: {
			connectedSources = sources;
			
			categorizeAppsTimer.start();
		}
	}
	
	// App Categorization and Search "Thread"
	Timer {
		id: categorizeAppsTimer
		repeat: true
		interval: 1
		triggeredOnStart: false
		onTriggered: {
			
			if(!getMenuItems(appSearchQuery)) {
				stop();
			}
			
		}
	}

	Component {
		id: appItem
		
		Item {
			width: 128
			height: 128
			
// 			PlasmaWidgets.IconWidget {
// 				text: modelData.name
// 				icon: QIcon(modelData.iconName)
// 				preferredIconSize: "48x48"
// 				minimumIconSize: "48x48"
// 				drawBackground: true
//
// 				anchors.fill: parent
//
// 				onClicked: {
// 					var operation = appsSource.serviceForSource(modelData.menuId).operationDescription("launch");
// 					appsSource.serviceForSource(modelData.menuId).startOperationCall(operation);
//
// 					// hide dashboard
// 					toggleLauncher();
// 				}
// 			}
		}
	}
	
	Component {
		id: categoryItem
		
		Plasma.ToolButton {
			width: 150
			text: modelData.name
			iconSource: "plasmapackage:/images/blank.png" // use blank icon to left-align text
			
			onClicked: {
				
				categoriesList.currentIndex = index;
				
				appGrid.model = Apps.categories[modelData.name].apps;
				
			}
		}
		
	}

	GridView {
		id: appGrid
		anchors {
			top: parent.top
			left: parent.left
			bottom: parent.bottom
			right: categoriesList.left
			rightMargin: 20
		}
		
		cellWidth: 170
		cellHeight: 170
		delegate: appItem
	}
	
		
	Plasma.ScrollBar {
		id: appGridScroll
		anchors {
			top: appGrid.top
			right: appGrid.right
			bottom: appGrid.bottom
		}
		flickableItem: appGrid
	}
	
	ListView {
		id: categoriesList
		width: 150
		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
		}
	
		delegate: categoryItem
		highlight: Plasma.Highlight {
			pressed: true
		}
	}
	
}
