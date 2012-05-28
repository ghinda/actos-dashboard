import QtQuick 1.1;
import org.kde.plasma.core 0.1 as PlasmaCore;
import org.kde.plasma.components 0.1 as Plasma;
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets;
import org.kde.qtextracomponents 0.1 as QtExtra;

//import "plasmapackage:/code/apps.js" as Apps
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
		
		if (sources[i] != "---") {
			
			if (Apps.appNames.indexOf(entry["name"]) < 0 && entry["name"] != ".hidden") {
				
				Apps.appNames.push(entry["name"]);
				
				if (entry["isApp"] && entry["display"]) {
					
					var app = {
						source: sources[i],
						name: entry["name"],
						genericName: entry["genericName"],
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
			//getMenuItems(appSearchQuery);
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
			
			PlasmaWidgets.IconWidget {
				text: modelData.name
				icon: QIcon(modelData.iconName)
				preferredIconSize: "64x64"
				minimumIconSize: "64x64"
				drawBackground: true
				
				anchors.fill: parent
				
				onClicked: {
					var executablePath = modelData.entryPath.replace(/^.*[\\\/]/, '').replace(/.desktop/, '');
					executableSource.connectSource(executablePath);
				}
			}
		}
	}
	
	Component {
		id: categoryItem
		
		Plasma.ToolButton {
			width: 150
			text: modelData.name
			iconSource: 'plasmapackage:/images/blank.png' // use blank icon to left-align text
			
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
		
		cellWidth: 150
		cellHeight: 150
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