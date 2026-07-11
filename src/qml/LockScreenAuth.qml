import Cutie
import Cutie.ScreenLock
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
	id: authPage

	CutieScreenLock {
		id: lockAuthClient
	}

	property string currentMethod: "none"
	property string targetMethod: "none"

	// verify -> enterNew -> confirmNew -> ready
	property string step: "verify"
	property string _firstEntry: ""
	property string errorText: ""

	onStepChanged: console.log("[DEBUG Auth] Step changed to:", step)

	function _methodLabel(key) {
		return key === "pin" ? qsTr("PIN")
			 : key === "pattern" ? qsTr("pattern")
			 : key === "password" ? qsTr("password")
			 : qsTr("none");
	}

	Component.onCompleted: {
		console.log("[DEBUG Auth] Page loaded. currentMethod:", currentMethod, "| targetMethod:", targetMethod);
		
		// Only PIN/pattern have a local secret worth re-confirming before a
		// change. Password is PAM's problem, and "none" has nothing to check.
		var needsVerify = (currentMethod === "pin" || currentMethod === "pattern");
		console.log("[DEBUG Auth] needsVerify evaluated to:", needsVerify);

		if (needsVerify) {
			step = "verify";
		} else if (targetMethod === "pin" || targetMethod === "pattern") {
			step = "enterNew";
		} else {
			console.log("[DEBUG Auth] No verification or new entry needed. Setting method directly and popping page.");
			lockAuthClient.setMethod(targetMethod);
			mainWindow.pageStack.pop();
		}
	}

	function _onVerified() {
		console.log("[DEBUG Auth] _onVerified called.");
		if (targetMethod === "pin" || targetMethod === "pattern") {
			errorText = "";
			step = "enterNew";
		} else {
			console.log("[DEBUG Auth] Setting method to", targetMethod, "and popping page.");
			lockAuthClient.setMethod(targetMethod);
			mainWindow.pageStack.pop();
		}
	}

	function _onVerifyFailed() {
		console.log("[DEBUG Auth] _onVerifyFailed called.");
		errorText = qsTr("That %1 wasn't right - try again.").arg(_methodLabel(currentMethod));
		shakeAnim.start();
	}

	function _onFirstEntry(secret) {
		console.log("[DEBUG Auth] _onFirstEntry recorded secret length:", secret.length);
		_firstEntry = secret;
		errorText = "";
		step = "confirmNew";
	}

	function _onConfirmEntry(secret) {
		console.log("[DEBUG Auth] _onConfirmEntry checking match...");
		if (secret !== _firstEntry) {
			console.log("[DEBUG Auth] Secrets did NOT match.");
			errorText = qsTr("Those didn't match - let's try again.");
			_firstEntry = "";
			step = "enterNew";
			shakeAnim.start();
			return;
		}
		console.log("[DEBUG Auth] Secrets matched successfully.");
		errorText = "";
		step = "ready";
	}

	function _commit() {
		console.log("[DEBUG Auth] _commit triggered. Target method:", targetMethod);
		if (targetMethod === "pin") {
			console.log("[DEBUG Auth] Committing new PIN.");
			lockAuthClient.setPin(_firstEntry);
		} else {
			console.log("[DEBUG Auth] Committing new Pattern.");
			lockAuthClient.setPattern(_firstEntry);
		}
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

	ColumnLayout {
		id: authCard
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 40
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: 20

		CutieLabel {
			Layout.alignment: Qt.AlignHCenter
			text: authPage.errorText
			color: "#e05252"
			font.pixelSize: 13
			visible: authPage.errorText.length > 0
		}

		PinPad {
			id: pinPad
			Layout.alignment: Qt.AlignHCenter
			visible: (authPage.step === "verify" && authPage.currentMethod === "pin") ||
					 ((authPage.step === "enterNew" || authPage.step === "confirmNew") && authPage.targetMethod === "pin")
			onPinEntered: (pin) => {
				console.log("[DEBUG Auth] PIN entered. Current step:", authPage.step);
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
			Layout.alignment: Qt.AlignHCenter
			visible: (authPage.step === "verify" && authPage.currentMethod === "pattern") ||
					 ((authPage.step === "enterNew" || authPage.step === "confirmNew") && authPage.targetMethod === "pattern")
			onPatternEntered: (sequence) => {
				console.log("[DEBUG Auth] Pattern entered. Current step:", authPage.step);
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
			Layout.alignment: Qt.AlignHCenter
			visible: authPage.step === "ready"
			implicitWidth: 220
			implicitHeight: 56
			font.pixelSize: 16
			onClicked: {
				console.log("[DEBUG Auth] Confirm button clicked.");
				authPage._commit();
			}
		}

		CutieButton {
			buttonText: qsTr("Cancel")
			Layout.alignment: Qt.AlignHCenter
			implicitWidth: 220
			implicitHeight: 56
			font.pixelSize: 16
			onClicked: {
				console.log("[DEBUG Auth] Cancel button clicked. Popping page.");
				mainWindow.pageStack.pop();
			}
		}
	}
}
