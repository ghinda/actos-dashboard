import QtQuick 1.1
import org.kde.plasma.components 0.1 as Plasma

Item {
	clip: true
	anchors.fill: parent
	
	GridView {
		id: activitiesGrid
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: 1
			bottom: parent.bottom
			right: parent.right
		}
		
		cellWidth: 260
		cellHeight: 180
		model: activitiesModel
		delegate: ActivityItem {}
	}
	
	Plasma.ScrollBar {
		anchors {
			top: activitiesGrid.top
			right: activitiesGrid.right
			bottom: activitiesGrid.bottom
		}
		flickableItem: activitiesGrid
	}

}