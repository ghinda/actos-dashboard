import QtQuick 1.1
import org.kde.plasma.core 0.1

Item {
	property int size : parent.height
	property string svgElementId : 'close'
	signal clicked
	
	width: size
	height: size
	
	SvgItem {
		id: configIcon
		svg: Svg {
			imagePath: 'widgets/configuration-icons'
			usingRenderingCache: true
		}
		elementId: svgElementId
		
		width: parent.height / 2
		height: parent.height / 2
		
		anchors {
			verticalCenter: parent.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}
	}
	
	// stop icon
	Rectangle {
		id: stopIcon
		visible: false
		width: parent.height / 3
		height: parent.height / 3
		
		color: '#fefefe'
		opacity: 0.7
		
		anchors {
			verticalCenter: parent.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}
	}
	
	MouseArea {
		anchors.fill: parent
		onPressed: {
			configIcon.width = configIcon.height = configIcon.height * 0.9; // 90%
		}
		
		onReleased: {
			configIcon.width = configIcon.height = size;
		}
		
		onClicked: parent.clicked()
	}
	
	Component.onCompleted: {
		if(svgElementId == 'stop') {
			configIcon.destroy();
			stopIcon.visible = true;
		}
		
	}
	
}