import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import Qt5Compat.GraphicalEffects // Импортируем официальный модуль эффектов для Qt6

Item {
    id: root
    width: 1920
    height: 1080

    // Имя пользователя по умолчанию из конфигурации
    property string realUsername: userModel.lastUser ? userModel.lastUser : (config.defaultUser || "User")

    // Подключаем ваш кастомный шрифт Daneehand Regular
    FontLoader {
        id: isleFont
        source: "fonts/daneehandregular.otf"
    }

    // 1. Полноэкранный задний фон (Ваш скриншот с динозаврами)
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.Background || "backgrounds/background.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // 2. Левая панель интерфейса (Сайдбар)
    Item {
        id: leftPanel
        width: root.width * 0.35 // Занимает 35% экрана слева
        height: root.height
        anchors.left: parent ? parent.left : undefined
        clip: true

        // Посредник, который вырезает точный кусок из фонового изображения экрана
        ShaderEffectSource {
            id: blurSource
            sourceItem: backgroundImage // Берём оригинальный фоновый рисунок всего экрана
            sourceRect: Qt.rect(0, 0, leftPanel.width, leftPanel.height) // Вырезаем только левую часть 1-в-1
            live: false // Не пересчитывать каждый кадр ради экономии ресурсов
        }

        // --- НАДЁЖНЫЙ БЛЮР QT6 НАД ПРАВИЛЬНЫМ КУСКОМ КАРТИНКИ ---
        FastBlur {
            anchors.fill: parent
            source: blurSource
            radius: 50 // Степень размытия (от 0 до 64)
        }

        // Цветовой фильтр поверх размытия (Темный цвет мокрых скал ColorDark)
        Rectangle {
            anchors.fill: parent
            color: config.ColorDark || "#1B1E22"
            opacity: 0.7
        }

        // --- ИСПРАВЛЕННАЯ АККУРАТНАЯ ТОНКАЯ РАМКА С ПРАВОЙ СТОРОНЫ БЛЮРА ---
        Rectangle {
            id: rightBorderShadow
            width: 2 // Тонкий графический контур
            height: parent.height
            anchors.right: parent.right
            color: "#000000" // Чистый черный цвет
            opacity: 0.4 // Мягкая прозрачность стыка
        }

        // Тонкая финишная нить для объема (Серо-зеленый ColorAccent)
        Rectangle {
            width: 1
            height: parent.height
            anchors.right: rightBorderShadow.left 
            color: config.ColorAccent || "#5C6F65"
            opacity: 0.15 
        }
    } // Конец блока leftPanel

    // 3. Контейнер UI элементов внутри левой заблюренной панели
    Item {
        id: uiContainer
        anchors.left: leftPanel.left; anchors.top: leftPanel.top; anchors.margins: 45
        width: leftPanel.width - 90; height: root.height - 90

        // Текст приветствия в стиле The Isle
        Text {
            id: welcomeText
            anchors.top: uiContainer.top; anchors.left: uiContainer.left; anchors.right: uiContainer.right
            text: "Welcome back, <b>" + root.realUsername + "</b>,<br>what day have you been surviving on the isle?"
            font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20"); color: config.ColorLight || "#D2D7DF"
            wrapMode: Text.Wrap; lineHeight: 1.2
            opacity: 0.9
        }

        // Блок живых часов и текущей даты
        Column {
            id: clockBlock
            anchors.top: welcomeText.bottom; anchors.topMargin: 30
            anchors.left: uiContainer.left; anchors.right: uiContainer.right; spacing: 5
            
            Text {
                id: clockTime
                text: Qt.formatTime(new Date(), "hh:mm:ss")
                font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20") * 2.2; color: config.ColorLight || "#D2D7DF"
            }
            Text {
                id: clockDate
                text: Qt.formatDate(new Date(), "dddd, MMMM d")
                font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20") * 0.8; color: config.ColorLight || "#D2D7DF"; opacity: 0.6
            }
            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: {
                    clockTime.text = Qt.formatTime(new Date(), "hh:mm:ss")
                    clockDate.text = Qt.formatDate(new Date(), "dddd, MMMM d")
                }
            }
        }

        // Вертикальный блок формы авторизации
        Item {
            id: formBlock
            anchors.top: clockBlock.bottom; anchors.topMargin: 35
            anchors.left: uiContainer.left; anchors.right: uiContainer.right; height: 250; z: 10

            // Поле логина (Имя пользователя)
            TextField {
                id: usernameField
                anchors.top: formBlock.top; width: formBlock.width; height: 40; text: root.realUsername
                placeholderText: "Username"; font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20") - 4
                color: usernameField.activeFocus ? (config.ColorAccent || "#5C6F65") : (config.ColorLight || "#D2D7DF")
                placeholderTextColor: Qt.rgba(210/255, 215/255, 223/255, 0.3)
                background: Rectangle {
                    color: config.ColorInputBg || "#0E1113"
                    border.color: usernameField.activeFocus ? (config.ColorAccent || "#5C6F65") : "#2D3238"
                    border.width: usernameField.activeFocus ? 2 : 1; radius: 4
                }
            }

            // Поле ввода пароля
            TextField {
                id: passwordField
                anchors.top: usernameField.bottom; anchors.topMargin: 18; width: formBlock.width; height: 40
                placeholderText: "Enter password to survive..."; echoMode: TextInput.Password; font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20") - 4
                color: passwordField.activeFocus ? (config.ColorAccent || "#5C6F65") : (config.ColorLight || "#D2D7DF"); focus: true
                placeholderTextColor: Qt.rgba(210/255, 215/255, 223/255, 0.3)
                background: Rectangle {
                    color: config.ColorInputBg || "#0E1113"
                    border.color: passwordField.activeFocus ? (config.ColorAccent || "#5C6F65") : "#2D3238"
                    border.width: passwordField.activeFocus ? 2 : 1; radius: 4
                }
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(usernameField.text, passwordField.text, sessionList.currentIndex)
                    }
                }
            }
            // Кнопка-селектор для отображения выбранной сессии
            Rectangle {
                id: sessionSelector
                anchors.top: passwordField.bottom; anchors.topMargin: 18; width: formBlock.width; height: 40
                color: config.ColorInputBg || "#0E1113"
                border.color: isOpen ? (config.ColorAccent || "#5C6F65") : "#2D3238"; border.width: 1; radius: 4
                property bool isOpen: false
                
                Text {
                    anchors.left: sessionSelector.left; anchors.leftMargin: 15; anchors.verticalCenter: sessionSelector.verticalCenter
                    text: sessionModel.data(sessionModel.index(sessionList.currentIndex, 0), Qt.DisplayRole) || "Select Session"
                    font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20") - 6
                    color: sessionSelector.isOpen ? (config.ColorAccent || "#5C6F65") : (config.ColorLight || "#D2D7DF")
                }
                Text {
                    anchors.right: sessionSelector.right; anchors.rightMargin: 15; anchors.verticalCenter: sessionSelector.verticalCenter
                    text: sessionSelector.isOpen ? "▲" : "▼"; font.pixelSize: 10; color: sessionSelector.isOpen ? (config.ColorAccent || "#5C6F65") : (config.ColorLight || "#D2D7DF")
                }
                MouseArea { anchors.fill: parent; onClicked: sessionSelector.isOpen = !sessionSelector.isOpen }
            }

            // Кнопка входа (Survive)
            Button {
                id: loginButton
                anchors.top: sessionSelector.bottom; anchors.topMargin: 18; width: formBlock.width; height: 40
                text: "Survive"; font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20") - 4; font.bold: true
                contentItem: Text {
                    text: loginButton.text; font: loginButton.font
                    color: loginButton.hovered ? (config.ColorDark || "#1B1E22") : (config.ColorLight || "#D2D7DF")
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: loginButton.hovered ? (config.ColorLight || "#D2D7DF") : "transparent"
                    border.color: config.ColorLight || "#D2D7DF"; border.width: 1; radius: 4; opacity: loginButton.pressed ? 0.8 : 1.0
                }
                onClicked: { sddm.login(usernameField.text, passwordField.text, sessionList.currentIndex) }
            }

            // Кастомное выпадающее меню списка сессий (KDE, Hyprland и т.д.)
            Rectangle {
                id: dropdownMenu
                visible: sessionSelector.isOpen; anchors.top: sessionSelector.bottom; anchors.topMargin: 2
                width: sessionSelector.width; height: Math.min(sessionModel.count * 40, 160)
                color: config.ColorInputBg || "#0E1113"; border.color: config.ColorAccent || "#5C6F65"; border.width: 1; radius: 4; z: 99
                
                ListView {
                    id: sessionList; anchors.fill: parent; model: sessionModel; currentIndex: sessionModel.lastIndex; clip: true
                    delegate: Rectangle {
                        width: dropdownMenu.width; height: 40
                        color: delegateMouse.containsMouse ? Qt.rgba(92/255, 111/255, 101/255, 0.2) : "transparent"
                        
                        Text {
                            anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter
                            text: model.name; color: delegateMouse.containsMouse ? (config.ColorAccent || "#5C6F65") : (config.ColorLight || "#D2D7DF")
                            font.family: isleFont.name; font.pixelSize: parseInt(config.FontSize || "20") - 6
                        }
                        MouseArea {
                            id: delegateMouse; anchors.fill: parent; hoverEnabled: true
                            onClicked: { sessionList.currentIndex = index; sessionSelector.isOpen = false }
                        }
                    }
                }
            }

            // Блок вывода текста ошибки в самом низу формы
            Text {
                id: errorMessage
                anchors.top: dropdownMenu.visible ? dropdownMenu.bottom : loginButton.bottom
                anchors.topMargin: 12; anchors.horizontalCenter: formBlock.horizontalCenter
                text: ""
                font.family: isleFont.name; font.pixelSize: 14
                color: "#A24444"
            }
        }
    }

    // Обработчик сигналов от демона SDDM при неверном пароле
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "The Isle rejected your credentials. Try again."
            passwordField.text = ""
            passwordField.focus = true
        }
    }
}
