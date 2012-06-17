import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as Plasma
import org.kde.qtextracomponents 0.1 as QtExtra
import org.kde.kwin 0.1 as KWin
 
Component {

	Item {
		property int clientWidth: client.width
		property int clientHeight: client.height
		
		property real ratio : clientWidth / clientHeight
		
		property int maxWidth : item.height * ratio
		property int maxHeight : item.height
	
		property real mX
		property real mY
		
		id: main
        width: grid.cellWidth
		height: grid.cellHeight
        
        Item {
            id: item
            parent: loc
            x: main.x
            y: main.y
            
            width: main.width - 20 // 5px margin l/r
			height: main.height - topControls.height - 10 // 5px margin from top controls to top thumb
            
            // Top controls
			PlasmaCore.FrameSvgItem {
				id: topControls
				height: 32
				imagePath: 'widgets/frame'
				prefix: 'plain'
				z: 3
				
				anchors {
					topMargin: 40
					left: thumb.left
					right: thumb.right
					bottom: thumb.top
				}
				
				ConfigIcon {
					id: closeWindow
					svgElementId: 'close'
					opacity: 0
					anchors.left: parent.left
					
					onClicked: {
						// close window
						client.closeWindow();
					}
					
					states: State {
						name: 'show'
						PropertyChanges {
							target: closeWindow
							opacity: 1
						}
					}

					transitions: Transition {
						PropertyAnimation { property: "opacity"; duration: 100 }
					}
				}
				
				Plasma.Label {
					text: client.caption
					elide: Text.ElideLeft
					horizontalAlignment: Text.AlignRight
					opacity: 0.8
					anchors {
						verticalCenter: parent.verticalCenter
						left: closeWindow.right
						leftMargin: 5
						right: parent.right
						rightMargin: 10
					}
				}
				
				/*
				QtExtra.QIconItem {
					id: appIcon
					width: 22
					height: 22
					icon: QIcon(client.icon)
					
					anchors {
						top: parent.top
						topMargin: 5
						right: parent.right
						rightMargin: 5
					}
				}
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: topControls
						opacity: 1
					}
				}
				*/
			
			}
            
            KWin.ThumbnailItem {
				id: thumb
				anchors {
					verticalCenter: item.verticalCenter
					horizontalCenter: item.horizontalCenter
				}
				width: (clientWidth < clientHeight) ? maxWidth : item.width
				height: (clientWidth < clientHeight) ? maxHeight : item.width / ratio
				parentWindow: dashboardContent.windowId
				clip: false
				wId: windowId
			}
            
            Behavior on x {
				enabled: item.state != "active"
				NumberAnimation {
					duration: 100
					easing.type: Easing.OutBack
				}
			}
			
            Behavior on y {
				enabled: item.state != "active"
				NumberAnimation {
					duration: 100
					easing.type: Easing.OutBack
				}
			}
            
            states: State {
                name: "active"
				when: loc.currentId == gridId
                
                PropertyChanges {
					target: item
					width: main.width + 20
					height: main.height + 20
					x: mX - width / 2;
					y: mY - height / 2;
					z: 10
				}
				
				PropertyChanges {
					target: topControls
					opacity: 0
				}
            }
            
            transitions: Transition {
				NumberAnimation {
					property: "width"
					duration: 100
				}
			}
			
			MouseArea {
				height: thumb.height + 30
				z: 2
				anchors {
					left: thumb.left
					right: thumb.right
					bottom: thumb.bottom
				}
				hoverEnabled: true
				onEntered: {
					//topControls.state = 'show';
					closeWindow.state = 'show';
				}
				onExited: {
					//topControls.state = '';
					closeWindow.state = '';
				}
				onPressed: {

					loc['pressAndHold'](mouse);
					
				}
				onReleased: {
					
					loc['released'](mouse);
				
				}
				onMousePositionChanged: {
					
					mX = item.x + mouse.x;
					mY = item.y + mouse.y;
					
					loc.mX = mX;
					loc.mY = mY;
					
					loc['mousePositionChanged'](mouse);
					
				}
			}
			
        }
        
        Connections {
			target: client
			
			onGeometryChanged: {
				clientHeight = client.height;
				clientWidth = client.width;
			}
		}
		
    }
}