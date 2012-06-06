import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as Plasma
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.kwin 0.1 as KWin
 
Component {

	Item {
		property real ratio : client.width / client.height
		property int maxWidth : (item.height - topControls.height - 5) * ratio
		property int maxHeight : (item.height - topControls.height - 5) - 30
	
		property real mX
		property real mY
		
		id: main
        width: grid.cellWidth
		height: grid.cellHeight
        
        Item {
            id: item
            parent: loc
            x: main.x + 5
            y: main.y + 5
            width: main.width - 10
			height: main.height - 10
            
            // Top controls
			PlasmaCore.FrameSvgItem {
				id: topControls
				z: 2
				height: 32
				opacity: 0
				imagePath: 'widgets/frame'
				prefix: 'plain'
				
				anchors {
					left: thumb.left
					right: thumb.right
					bottom: thumb.top
				}
				
				ConfigIcon {
					id: closeWindow
					svgElementId: 'close'
					
					anchors.left: parent.left
					
					onClicked: {
						// close window
						client.closeWindow();
					}
				}
				
				Plasma.Label {
					text: client.caption
					elide: Text.ElideLeft
					horizontalAlignment: Text.AlignRight
					anchors {
						verticalCenter: parent.verticalCenter
						left: closeWindow.right
						leftMargin: 5
						right: appIcon.left
						rightMargin: 5
					}
				}
				
				PlasmaWidgets.IconWidget {
					id: appIcon
					icon: QIcon(client.icon)
					preferredIconSize: "22x22"
					minimumIconSize: "16x16"
					drawBackground: true
					
					anchors {
						top: parent.top
						right: parent.right
					}
				}
				
				states: State {
					name: 'show'
					PropertyChanges {
						target: topControls
						opacity: 1
					}
				}

				transitions: Transition {
					PropertyAnimation { property: "opacity"; duration: 100 }
					PropertyAnimation { property: "y"; duration: 100 }
				}
			
			}
            
            // TODO Fix issues when height>width (like konsole), with unreachable close button
            
            KWin.ThumbnailItem {
				id: thumb
				anchors {
					verticalCenter: item.verticalCenter
					horizontalCenter: item.horizontalCenter
				}
				width: (client.width < client.height) ? maxWidth : item.width
				height: (client.width < client.height) ? maxHeight : item.width / ratio - 30
				parentWindow: dashboardContent.windowId
				clip: false
				wId: windowId
				z: 1
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
            }
            
            transitions: Transition {
				NumberAnimation {
					property: "width"
					duration: 200
				}
			}
			
			MouseArea {
				anchors.fill: item
				hoverEnabled: true
				onEntered: {
					topControls.state = 'show';
				}
				onExited: {
					topControls.state = '';
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
        
        
    }
}