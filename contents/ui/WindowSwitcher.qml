import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as Plasma
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.kwin 0.1 as KWin

Item {
	anchors.fill: parent
	clip: false
	
	property int cellSize : 100
	property int columns
	property int rows
	property int thumbsInside
	property int tempCellSize
	
	width: parent.width
	height: parent.height
	
	ListModel {
		id: windowThumbs
	}
	
	GridView {
		id: grid
		interactive: false
		width: parent.width
		height: parent.height
		
		cellWidth: cellSize
		cellHeight: cellSize
		
		model: windowThumbs
		delegate: WindowThumbItem { }
		
		MouseArea {
			property int currentId: -1                       // Original position in model
			property int newIndex                            // Current Position in model
			property real mX
			property real mY
			property int index: grid.indexAt(loc.mX, loc.mY) // Item underneath cursor
			property variant clickTimer
			property bool mouseMoved : false
			
			id: loc
			anchors.fill: parent
			z: 1
			
			onPressAndHold: {
				index = grid.indexAt(loc.mX, loc.mY);
				mouseMoved = false;
				
				// if clicked on a thumb
				if(index != -1) {
					currentId = windowThumbs.get(newIndex = index).gridId
					
					// get current time
					clickTimer = new Date();
				}
			}
			onReleased: {
				currentId = -1;
				
				if(index != -1) {
				
					/* calculate miliseconds from press
					* to check if it was click or drag
					*/
					clickTimer = new Date() - new Date(clickTimer);
					
					if(clickTimer < 270 && !mouseMoved) {
						// hide dashboard
						//toggleLauncher();
						
						// unminimize everything
						workspace.slotToggleShowDesktop();
						
						// activate client
						workspace.activeClient = windowThumbs.get(index).client;
					};
					
				};
			}
			onMousePositionChanged: {
				index = grid.indexAt(loc.mX, loc.mY);
				
				if (loc.currentId != -1 && index != -1 && index != newIndex) {
					windowThumbs.move(newIndex, newIndex = index, 1)
					
					mouseMoved = true;
				}
				
			}
		}
		
	}
    
    // check if the client should be visible in the windowSwitcher
    function visibleClient(client) {
		if(client.dock || client.skipSwitcher || client.skipTaskbar) {
			return false;
		} else {
			return true;
		}
	}
    
    // get clients from KWin and add to model
    Component.onCompleted: {
		
		// add data to model
		var clients = workspace.clientList();
		
		var i = 0;
		for (i = 0; i < clients.length; i++) {
			
			if(visibleClient(clients[i])) {
				
				windowThumbs.append({
					"windowId": clients[i].windowId,
					"gridId": windowThumbs.count,
					"client": clients[i]
				});
				
			}
			
		}
		
		// recalculate thumb size
		recalculateCellSize();
		
		// Meta + Digit global shortcuts to each window
		var i = 0;
		for (i = 1; i < 10; i++) {
			// self-invoking closure
			// to be able to keep the real index local
			(function() {
				var index = i - 1;
				registerShortcut("Activate Window " + i, "", "Meta+" + i, function() {
					if(windowThumbs.get(index)) workspace.activeClient = windowThumbs.get(index).client;
				});
			})();
		}
		
    }
    
    // adding and removing clients
    Connections {
        target: workspace
        
		// connections for when clients are added and removed
		onClientAdded: {
			
			if(visibleClient(client)) {
			
				windowThumbs.append({
					"windowId": client.windowId,
					"gridId": windowThumbs.count,
					"client": client
				});
			
			}
			
			// recalculate thumb size
			recalculateCellSize();
			
		}
		
		onClientRemoved: {
			
			var i;
			for(i = 0; i < windowThumbs.count; i++) {
				
				if(windowThumbs.get(i).client == client) {
					windowThumbs.remove(i);
					
					// recalculate thumb size
					recalculateCellSize();
					
					return false;
				}
				
			};
			
		}
    }
    
    // thumb resizer "thread"
    Timer {
		id: fitCellSize
		interval: 150
		running: false
		repeat: true
		onTriggered: {
			
			// get number of rows and columns that fit in container
			columns = parseInt(grid.width / tempCellSize);
			rows = parseInt(grid.height / tempCellSize);
			thumbsInside = columns * rows;
			
			if(thumbsInside >= windowThumbs.count) {
				
				// stop the timer
				fitCellSize.running = false;
				cellSize = tempCellSize;
				
			} else {
				
				// use a temporary cellSize, to not resize items with values that are not final
			
				// decrease 10 pixels each time
				tempCellSize -= 10;
				
			}
			
		}
	}
    
	// recalculate cell size
    function recalculateCellSize() {
		
		tempCellSize = Math.sqrt((grid.width * grid.height) / windowThumbs.count);
		
		// check if all thumbs fit in grid
		fitCellSize.running = true;
	}
    
}