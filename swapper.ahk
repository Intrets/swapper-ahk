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

    return { list: list, gui: MyGui }
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

    loop 10 {
        i := A_Index
        saveList(f, guis[i].list)
    }

    f.Close()
}

loadState() {
    try {
        f := FileOpen("state.txt", "r")

        loop 10 {
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

loop 10 {
    guis.Push(createGui("Window " A_Index))
}

loadState()

focusOn(index) {
    list := guis[index].list

    loop list.GetCount() {
        i := A_Index
        target := list.GetText(i)
        WinActivate("ahk_exe " target)
    }
}

runGui(index) {
    loop 10 {
        gui := guis[A_Index].gui
        if A_Index == index {
            gui.Show()
        }
        else {
            gui.Hide()
        }
    }
}

!1:: focusOn(1)
!+1:: runGui(1)

!2:: focusOn(2)
!+2:: runGui(2)

!3:: focusOn(3)
!+3:: runGui(3)

!4:: focusOn(4)
!+4:: runGui(4)

!5:: focusOn(5)
!+5:: runGui(5)

!6:: focusOn(6)
!+6:: runGui(6)

!7:: focusOn(7)
!+7:: runGui(7)

!8:: focusOn(8)
!+8:: runGui(8)

!9:: focusOn(9)
!+9:: runGui(9)

!0:: focusOn(10)
!+0:: runGui(10)