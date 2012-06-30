import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as Plasma

Component {
	
	Item {
		id: root
		
		width: 250
		height: 170
		
		// Edit controls
		PlasmaCore.FrameSvgItem {
			id: editControls
			y: 10
			height: 30
			opacity: 0
			imagePath: 'widgets/frame'
			prefix: 'plain'
			
			anchors {
				left: wallpaper.left
				right: wallpaper.right
			}
			
			ConfigIcon {
				id: editDelete
				svgElementId: 'close'
				visible: model.State != 'Running'
				
				anchors.left: parent.left
				
				onClicked: {
					// show delete prompt
					root.state = 'delete';
					// hide edit filed
					activityLabel.state = '';
				}
			}
			
			ConfigIcon {
				id: editStop
				svgElementId: 'stop'
				visible: (model.State == 'Running') && (Current != true)
				
				anchors.left: parent.left
				
				onClicked: {
					// stop activity
					var operation = activitiesSource.serviceForSource(DataEngineSource).operationDescription('stop');
					activitiesSource.serviceForSource(DataEngineSource).startOperationCall(operation);
				}
				
			}
			
			ConfigIcon {
				id: editButton
				svgElementId: 'configure'
				
				anchors.right: parent.right
				
				onClicked: {
					
					if(activityLabel.state == 'edit') {
						activityLabel.state = '';
						
						// save new model name
						var operation = activitiesSource.serviceForSource(DataEngineSource).operationDescription('setName');
						operation.Name = activityTitleField.text;
						
						activitiesSource.serviceForSource(DataEngineSource).startOperationCall(operation);
					} else {
						activityLabel.state = 'edit';
					}
					
				}
				
			}
			
			states: State {
				name: 'show'
				PropertyChanges {
					target: editControls
					opacity: 1
					y: 0
				}
			}

			transitions: Transition {
				PropertyAnimation { property: "opacity"; duration: 100 }
				PropertyAnimation { property: "y"; duration: 100 }
			}
		
		}
		
		// Entire MouseArea
		MouseArea {
			z: 9
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			
			onEntered: {
				if(parent.state != 'create') {
					editControls.state = 'show';
					wallpaper.state = 'highlight';
				}
			}
			
			onExited: {
				if(parent.state != 'create') {
					editControls.state = '';
					wallpaper.state = '';
				}
			}
			
			onClicked: {
				forwardEvent(mouse, "clicked");
			}

			// forward click events
			function forwardEvent(event, eventType) {
				mouseArea.visible = false;
				var item = editControls.childAt(event.x, event.y),
					parentItem = parent.childAt(event.x, event.y);
				mouseArea.visible = true;
				
				if (item && item != mouseArea && typeof(item[eventType]) == "function") {
					item[eventType](event);
				} else if(parentItem && parentItem != mouseArea && typeof(parentItem[eventType]) == "function") {
					parentItem[eventType](event);
				}
			}
			
		}
		
		// Wallpaper
		Image {
			id: wallpaper
			width: 250
			height: 140
			fillMode: Image.PreserveAspectCrop
			smooth: true
			clip: true
			opacity: 0.7
			source: Icon || ''
			
			anchors {
				top: parent.top
				topMargin: editControls.height
			}
			
			states: State {
				name: 'highlight'
				PropertyChanges {
					target: wallpaper
					opacity: 1
				}
			}

			transitions: Transition {
				PropertyAnimation { property: "opacity"; duration: 100 }
			}
			
			onStatusChanged: {
				var source = wallpaper.source + '';
				
				if (wallpaper.status == Image.Error) {
					if(source.slice( -3 ) != 'jpg') {
						wallpaper.source = source.slice(0, -3) + 'jpg';
					} else {
						wallpaper.source = '../images/defaultWallpaper.png';
					}
				}
				
			}
		}
		
		// Wallpaper MouseArea
		MouseArea {
			z: 8
			anchors.fill: wallpaper
			onClicked: {
				
				var operation;
				
				if(model.State != 'Running') {
					operation = activitiesSource.serviceForSource(DataEngineSource).operationDescription('start');
					activitiesSource.serviceForSource(DataEngineSource).startOperationCall(operation);
				}
				
				if(!Current) {
					operation = activitiesSource.serviceForSource(DataEngineSource).operationDescription('setCurrent');
					activitiesSource.serviceForSource(DataEngineSource).startOperationCall(operation);
				}
				
				// hide dashboard
				toggleLauncher();
				
			}
		}
		
		// Text label
		PlasmaCore.FrameSvgItem {
			id: activityLabel
			imagePath: 'widgets/viewitem'
			prefix: 'normal'
			height: 30
			visible: parent.state != 'create'
			
			anchors {
				bottom: wallpaper.bottom
				left: parent.left
				right: parent.right
			}
		
			Plasma.Label {
				anchors {
					left: parent.left
					leftMargin: 10
				}
				text: Name || ''
				visible: parent.state != 'edit'
			}
			
			Plasma.TextField {
				id: activityTitleField
				text: Name || ''
				visible: parent.state == 'edit'
				anchors {
					fill: parent
					margins: 5
				}
				
				Keys.onPressed: {
					
					if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
						
						// trigger click on edit
						editButton.clicked();
						
					};
				}
			}
			
			states: State {
				name: 'edit'
				
				PropertyChanges {
					target: activityTitleField
					focus: true
				}
				
				PropertyChanges {
					target: activityLabel
					z: 11
				}
			}
			
		}
		
		// Delete Confirmation
		PlasmaCore.FrameSvgItem {
			id: deleteFrame
			z: 11
			imagePath: 'widgets/viewitem'
			prefix: 'selected'
			anchors.fill: wallpaper
			visible: parent.state == 'delete'
		
			Plasma.Label {
				anchors {
					bottom: deleteButtonRow.top
					horizontalCenter: parent.horizontalCenter
				}
				id: deleteQuestion
				
				text: 'Really delete this activity?'
			}
			
			Row {
				id: deleteButtonRow
				anchors.centerIn: parent
				spacing: 2
				z: 1
				
				Plasma.Button {
					width: deleteFrame.width/3
					text: 'Delete'
					onClicked: {
						// delete activity
						var operation = activitiesSource.serviceForSource(DataEngineSource).operationDescription('remove');
						operation.Id = DataEngineSource;
						activitiesSource.serviceForSource(DataEngineSource).startOperationCall(operation);
						
					}
				}
				
				Plasma.Button {
					width: deleteFrame.width/3
					text: 'Cancel'
					
					onClicked: {
						root.state = '';
					}
				}
			}
			
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
			}
			
		}
		
		// Create Activity Item
		PlasmaCore.FrameSvgItem {
			id: addActivity
			imagePath: 'widgets/viewitem'
			prefix: 'hover'
			anchors.fill: parent
			anchors.topMargin: editControls.height
			visible: parent.state == 'create'
			opacity: 0.8
			
			ConfigIcon {
				size: parent.height / 2
				svgElementId: 'add'
				
				anchors.centerIn: parent
				
			}
		}
		
		MouseArea {
			z: 10
			anchors.fill: addActivity
			visible: parent.state == 'create'
			hoverEnabled: true
			
			onEntered: {
				addActivity.opacity = 1;
			}
			
			onExited: {
				addActivity.opacity = 0.8;
			}
			
			onClicked: {
				
				// create new activity
				var operation = activitiesSource.serviceForSource(DataEngineSource).operationDescription('add');
				operation.Name = 'New Activity';
				
				activitiesSource.serviceForSource(DataEngineSource).startOperationCall(operation);
				
			}
		}
		
		states: [
			State {
				name: 'create'
				when: DataEngineSource == 'Status'
			},
			
			State {
				name: 'delete'
				
				PropertyChanges {
					target: mouseArea
					anchors.fill: wallpaper
				}
			}
			
		]

	}
	
}