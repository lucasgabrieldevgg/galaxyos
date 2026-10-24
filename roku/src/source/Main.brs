'*************************************************************
'** GalaxyOS — Fase 1 · ponto de entrada
'** Padrão do sample oficial hello-world (roSGScreen + port).
'*************************************************************

sub Main()
    print "[App] GalaxyOS Fase 1 start"
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    scene = screen.CreateScene("HomeScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                print "[App] screen closed — exit"
                return
            end if
        end if
    end while
end sub
