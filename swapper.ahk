#Requires AutoHotkey v2.0

createGui(name) {
    MyGui := Gui(, name)

    inputList := MyGui.Add("ListBox", "h300 w700")

    list := MyGui.Add("ListView", "r20 w700", ["Executable"])

    refresh(*) {
        inputList.Delete()
        ids := WinGetList()
        for hwnd in ids {
            try {
                exe := WinGetProcessName("ahk_id " hwnd)
                if exe
                    inputList.Add([exe])
            }
        }
    }

    refresh()

    doubleClickInput(*) {
        list.Add(, inputList.Text)
        saveState()
    }

    inputList.OnEvent("DoubleClick", doubleClickInput)

    doubleClickList(*) {
        i := list.GetNext()
        if i > 0 && i <= list.GetCount() {
            list.Delete(i)
            saveState()
        }
    }

    list.OnEvent("DoubleClick", doubleClickList)

    return { list: list, gui: MyGui, data: { currentIndex: 1, currentId: -1 } }
}

saveList(f, list) {
    count := list.GetCount()

    f.WriteLine(count)

    loop list.GetCount() {
        i := A_Index
        target := list.GetText(i)
        f.WriteLine(target)
    }
}

saveState() {
    f := FileOpen("state.txt", "w")

    loop guis.Length {
        i := A_Index
        saveList(f, guis[i].list)
    }

    f.Close()
}

loadState() {
    try {
        f := FileOpen("state.txt", "r")

        loop guis.Length {
            i := A_Index
            loadList(f, guis[i].list)
        }

        f.Close()
    }
}

loadList(f, list) {
    count := f.ReadLine()

    list.Delete()
    loop count {
        line := f.ReadLine()
        list.Add(, line)
    }
}

guis := []

loop 22 {
    guis.Push(createGui("Window " A_Index))
}

loadState()

currentFocus := { type: "nothing" }
lastFocus := { type: "nothing" }

swapToLast() {
    global lastFocus
    global currentFocus

    if lastFocus.type == "single" {
        try {
            WinActivate(lastFocus.id)
        }
    }
    else if lastFocus.type == "group" {
        for id in lastFocus.ids {
            try {
                WinActivate(id)
            }
        }
    }

    temp := currentFocus
    currentFocus := lastFocus
    lastFocus := temp
}

has(array, item) {
    if !IsObject(item) || array.Length == 0 {
        return 0
    }

    for i, value in array {
        if value == item {
            return i
        }
    }

    return 0
}

focusOn(index) {
    global currentFocus
    global lastFocus
    global guis

    list := guis[index].list
    data := guis[index].data

    if list.GetCount() == 1 {
        target := list.GetText(1)
        ids := WinGetList("ahk_exe " target)

        currentId := WinGetID("A")
        exe := WinGetProcessName("A")

        data.currentIndex := Mod(data.currentIndex - 1, ids.Length) + 1
        same := exe == target && data.currentIndex >= 1 && data.currentIndex <= ids.Length && ids[data.currentIndex] == currentId

        if same {
            data.currentIndex := Mod(data.currentIndex, ids.Length) + 1
        }

        loop ids.Length {
            id := ids[data.currentIndex]
            title := WinGetTitle(id)

            if title != "" && !(exe == "explorer.exe" && title == "Program Manager") {
                if currentId != id || currentFocus != { type: "single", id: id } {
                    lastFocus := currentFocus
                    currentFocus := { type: "single", id: id }

                    data.currentId := id
                    try {
                        WinActivate(id)
                        break
                    }
                }
                else {
                    break
                }
            }

            data.currentIndex := Mod(data.currentIndex, ids.Length) + 1
        }
    }
    else {
        currentId := WinGetID("A")

        hasLast(ids, id) {
            if ids.Length == 0 {
                return False
            }
            else {
                return ids[ids.Length] == id
            }
        }

        if currentFocus.type != "group" || currentFocus.index != index || !hasLast(currentFocus.ids, currentId) {
            previousLastFocus := lastFocus
            lastFocus := currentFocus

            currentFocus := { type: "group", index: index, ids: [] }

            loop list.GetCount() {
                i := A_Index
                target := list.GetText(i)
                ids := WinGetList("ahk_exe " target)

                if ids.Length == 0 {
                    continue
                }
                else {
                    for id in ids {
                        title := WinGetTitle(id)
                        if title != "" {
                            currentFocus.ids.Push(id)
                            try {
                                WinActivate(id)
                                break
                            }
                        }
                    }
                }
            }

            if currentFocus.ids.Length == 0 {
                currentFocus := lastFocus
                lastFocus := previousLastFocus
            }
        }
    }
}

runGui(index, name) {
    loop guis.Length {
        gui := guis[A_Index].gui
        if A_Index == index {
            gui.Title := name
            gui.Show()
        }
        else {
            gui.Hide()
        }
    }
}

closeAll() {
    loop guis.Length {
        gui := guis[A_Index].gui
        gui.Hide()
    }
}

maximizeCurrent() {
    id := WinGetID("A")
    try {
        WinMaximize(id)
    }
}

restoreCurrent() {
    id := WinGetID("A")
    try {
        WinRestore(id)
    }
}

!`:: swapToLast()

; --------

!1:: focusOn(1)
!+1:: runGui(1, "1")

!2:: focusOn(2)
!+2:: runGui(2, "2")

!3:: focusOn(3)
!+3:: runGui(3, "3")

!4:: focusOn(4)
!+4:: runGui(4, "4")

!5:: focusOn(5)
!+5:: runGui(5, "5")

!6:: focusOn(6)
!+6:: runGui(6, "6")

!7:: focusOn(7)
!+7:: runGui(7, "7")

!8:: focusOn(8)
!+8:: runGui(8, "8")

!9:: focusOn(9)
!+9:: runGui(9, "9")

!0:: focusOn(10)
!+0:: runGui(10, "10")

; ------------------------------

!F1:: focusOn(11)
!+F1:: runGui(11, "F1")

!F2:: focusOn(12)
!+F2:: runGui(12, "F2")

!F3:: focusOn(13)
!+F3:: runGui(13, "F3")

; !F4:: focusOn(14)
; !+F4:: runGui(14, "F4")

!F5:: focusOn(15)
!+F5:: runGui(15, "F5")

!F6:: focusOn(16)
!+F6:: runGui(16, "F6")

!F7:: focusOn(17)
!+F7:: runGui(17, "F7")

!F8:: focusOn(18)
!+F8:: runGui(18, "F8")

!F9:: focusOn(19)
!+F9:: runGui(19, "F9")

!F10:: focusOn(20)
!+F10:: runGui(20, "F10")

!F11:: focusOn(21)
!+F11:: runGui(21, "F11")

!F12:: focusOn(22)
!+F12:: runGui(22, "F12")

~Escape:: closeAll()

!m:: maximizeCurrent()
!+m:: restoreCurrent()