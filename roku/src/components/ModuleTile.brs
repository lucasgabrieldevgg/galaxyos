'*************************************************************
'** GalaxyOS — ModuleTile
'** Tile de módulo do rail: estado focado = ring 4px + escala
'** 1.05 do centro + título em accent (transição <= 150ms por
'** construção: troca direta, sem animação bloqueante).
'*************************************************************

sub init()
    m.focusRing = m.top.findNode("focusRing")
    m.bgRect = m.top.findNode("bgRect")
    m.numLabel = m.top.findNode("numLabel")
    m.numRect = m.top.findNode("numRect")
    m.badgeRect = m.top.findNode("badgeRect")
    m.badgeLabel = m.top.findNode("badgeLabel")
    m.titleLabel = m.top.findNode("titleLabel")
    m.descLabel = m.top.findNode("descLabel")

    ' escala do centro do tile, não do canto
    m.top.scaleRotateCenter = [180, 115]

    ' tipografia explícita (piso de 24px no FHD — gate roku-design)
    m.numLabel.font.size = 40
    m.badgeLabel.font.size = 24
    m.titleLabel.font.size = 40
    m.descLabel.font.size = 24
end sub

sub onNumChanged()
    m.numLabel.text = m.top.num
end sub

sub onTitleChanged()
    m.titleLabel.text = m.top.title
end sub

sub onDescChanged()
    m.descLabel.text = m.top.desc
end sub

sub onBadgeChanged()
    m.badgeLabel.text = m.top.badgeText
    if m.top.badgeKind = "now"
        m.badgeRect.color = "0x6EE7FF21"
        m.badgeLabel.color = "0x6EE7FFFF"
    else
        m.badgeRect.color = "0x8B7CFF26"
        m.badgeLabel.color = "0x8B7CFFFF"
    end if
end sub

sub onFocusedChanged()
    focused = m.top.focused
    m.focusRing.visible = focused
    if focused
        m.top.scale = [1.05, 1.05]
        m.titleLabel.color = "0x6EE7FFFF"
        m.numRect.color = "0x6EE7FF33"
    else
        m.top.scale = [1.0, 1.0]
        m.titleLabel.color = "0xEDF1F9FF"
        m.numRect.color = "0x6EE7FF21"
    end if
end sub
