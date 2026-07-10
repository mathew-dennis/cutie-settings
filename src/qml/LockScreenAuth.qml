import Cutie
import Cutie.ScreenLock
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
	id: authPage

	ScreenLock {
		id: lockAuthClient
	}

	property string currentMethod: "none"
	property string targetMethod: "none"

	// verify -> enterNew -> confirmNew -> ready
	property string step: "verify"
	property string _firstEntry: ""
	property string errorText: ""

	function _methodLabel(key) {
		return key === "pin" ? qsTr("PIN")
			 : key === "pattern" ? qsTr("pattern")
			 : key === "password" ? qsTr("password")
			 : qsTr("none");
	}

	Component.onCompleted: {
		// Only PIN/pattern have a local secret worth re-confirming before a
		// change. Password is PAM's problem, and "none" has nothing to check.
		var needsVerify = (currentMethod === "pin" || currentMethod === "pattern");

		if (needsVerify) {
			step = "verify";
		} else if (targetMethod === "pin" || targetMethod === "pattern") {
			step = "enterNew";
		} else {
			lockAuthClient.setMethod(targetMethod);
			mainWindow.pageStack.pop();
		}
	}

	function _onVerified() {
		if (targetMethod === "pin" || targetMethod === "pattern") {
			errorText = "";
			step = "enterNew";
		} else {
			lockAuthClient.setMethod(targetMethod);
			mainWindow.pageStack.pop();
		}
	}

	function _onVerifyFailed() {
		errorText = qsTr("That %1 wasn't right - try again.").arg(_methodLabel(currentMethod));
		shakeAnim.start();
	}

	function _onFirstEntry(secret) {
		_firstEntry = secret;
		errorText = "";
		step = "confirmNew";
	}

	function _onConfirmEntry(secret) {
		if (secret !== _firstEntry) {
			errorText = qsTr("Those didn't match - let's try again.");
			_firstEntry = "";
			step = "enterNew";
			shakeAnim.start();
			return;
		}
		errorText = "";
		step = "ready";
	}

	function _commit() {
		if (targetMethod === "pin")
			lockAuthClient.setPin(_firstEntry);
		else
			lockAuthClient.setPattern(_firstEntry);
		lockAuthClient.setMethod(targetMethod);
		mainWindow.pageStack.pop();
	}

	CutiePageHeader {
		id: header
		title: qsTr("Lock Screen")
		description: {
			if (authPage.step === "verify")
				return qsTr("Enter your current %1 to continue.").arg(authPage._methodLabel(authPage.currentMethod));
			if (authPage.step === "enterNew")
				return qsTr("Set a new %1.").arg(authPage._methodLabel(authPage.targetMethod));
			if (authPage.step === "confirmNew")
				return qsTr("Enter it again to confirm.");
			return qsTr("Ready to save.");
		}
		width: parent.width
	}

	SequentialAnimation {
		id: shakeAnim
		NumberAnimation { target: authCard; property: "anchors.horizontalCenterOffset"; to: -20; duration: 50 }
		NumberAnimation { target: authCard; property: "anchors.horizontalCenterOffset"; to: 20; duration: 50 }
		NumberAnimation { target: authCard; property: "anchors.horizontalCenterOffset"; to: -12; duration: 50 }
		NumberAnimation { target: authCard; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
	}

	Column {
		id: authCard
		anchors.top: header.bottom
		anchors.topMargin: 30
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: 20

		CutieLabel {
			anchors.horizontalCenter: parent.horizontalCenter
			text: authPage.errorText
			color: "#e05252"
			font.pixelSize: 13
			visible: authPage.errorText.length > 0
		}

		PinPad {
			id: pinPad
			anchors.horizontalCenter: parent.horizontalCenter
			visible: (authPage.step === "verify" && authPage.currentMethod === "pin") ||
					 ((authPage.step === "enterNew" || authPage.step === "confirmNew") && authPage.targetMethod === "pin")
			onPinEntered: (pin) => {
				if (authPage.step === "verify") {
					if (lockAuthClient.verifyPin(pin)) authPage._onVerified();
					else authPage._onVerifyFailed();
				} else if (authPage.step === "enterNew") {
					authPage._onFirstEntry(pin);
				} else if (authPage.step === "confirmNew") {
					authPage._onConfirmEntry(pin);
				}
				pinPad.reset();
			}
		}

		PatternLock {
			id: patternLock
			anchors.horizontalCenter: parent.horizontalCenter
			visible: (authPage.step === "verify" && authPage.currentMethod === "pattern") ||
					 ((authPage.step === "enterNew" || authPage.step === "confirmNew") && authPage.targetMethod === "pattern")
			onPatternEntered: (sequence) => {
				if (authPage.step === "verify") {
					if (lockAuthClient.verifyPattern(sequence)) authPage._onVerified();
					else authPage._onVerifyFailed();
				} else if (authPage.step === "enterNew") {
					authPage._onFirstEntry(sequence);
				} else if (authPage.step === "confirmNew") {
					authPage._onConfirmEntry(sequence);
				}
				patternLock.reset();
			}
		}

		CutieButton {
			buttonText: qsTr("Confirm")
			anchors.horizontalCenter: parent.horizontalCenter
			visible: authPage.step === "ready"
			onClicked: authPage._commit()
		}

		CutieButton {
			buttonText: qsTr("Cancel")
			anchors.horizontalCenter: parent.horizontalCenter
			onClicked: mainWindow.pageStack.pop()
		}
	}
}
