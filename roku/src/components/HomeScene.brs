'*************************************************************
'** GalaxyOS — HomeScene (Fase 1)
'** Launcher home Deep Space: saudação por hora, relógio,
'** card de rede, rail de módulos (foco gerenciado pela cena
'** — ADR-0004) e painel de detalhe. Feed via Task (fallback
'** offline embutido). Idioma PT/EN via * (registro).
'*************************************************************

sub init()
    m.cfg = gxConfig()
    m.strings = gxStrings()

    m.lang = loadLang()
    m.modules = gxFallbackModules()
    m.focusIndex = 0

    m.clockLabel = m.top.findNode("clockLabel")
    m.wifiLabel = m.top.findNode("wifiLabel")
    m.greetingLabel = m.top.findNode("greetingLabel")
    m.heroSubLabel = m.top.findNode("heroSubLabel")
    m.netcardName = m.top.findNode("netcardName")
    m.netcardStatus = m.top.findNode("netcardStatus")
    m.sectionLabel = m.top.findNode("sectionLabel")
    m.offlineLabel = m.top.findNode("offlineLabel")
    m.railGroup = m.top.findNode("railGroup")
    m.detailTitle = m.top.findNode("detailTitle")
    m.detailDesc = m.top.findNode("detailDesc")
    m.detailStatus = m.top.findNode("detailStatus")
    m.hintLabel = m.top.findNode("hintLabel")

    buildRail()
    renderChrome()
    updateFocus()
    updateClock()

    ' tipografia explícita (roles do sistema podem vir < 24px no FHD)
    m.logoLabel.font.size = 44
    m.clockLabel.font.size = 40
    m.wifiLabel.font.size = 26
    m.greetingLabel.font.size = 72
    m.heroSubLabel.font.size = 30
    m.netcardName.font.size = 34
    m.netcardStatus.font.size = 26
    m.sectionLabel.font.size = 26
    m.offlineLabel.font.size = 26
    m.detailTitle.font.size = 48
    m.detailDesc.font.size = 28
    m.detailStatus.font.size = 26
    m.hintLabel.font.size = 24

    ' relógio: tick a cada 30s
    m.clockTimer = CreateObject("roSGNode", "Timer")
    m.clockTimer.duration = m.cfg.clockTickSeconds
    m.clockTimer.repeat = true
    m.clockTimer.observeField("fire", "onClockTick")
    m.clockTimer.control = "start"

    startFeed()

    m.railGroup.setFocus(true)
    print "[Home] init done — lang=" + m.lang
end sub

'──────────────────────── rail ────────────────────────

sub buildRail()
    tiles = m.railGroup.getChildren(-1, 0)
    for each tile in tiles
        m.railGroup.removeChild(tile)
    end for

    s = currentStrings()
    for i = 0 to m.modules.Count() - 1
        entry = m.modules[i]
        tile = CreateObject("roSGNode", "ModuleTile")
        tile.moduleId = entry.id
        tile.num = "0" + stri(i + 1).trim()
        tile.title = pick(entry, "title")
        tile.desc = pick(entry, "desc")
        tile.badgeKind = entry.badge
        tile.badgeText = badgeTextFor(entry)
        tile.translation = [96 + i * 400, 0]
        m.railGroup.appendChild(tile)
    end for
end sub

sub updateFocus()
    tiles = m.railGroup.getChildren(-1, 0)
    for i = 0 to tiles.Count() - 1
        tiles[i].focused = (i = m.focusIndex)
    end for

    entry = m.modules[m.focusIndex]
    m.detailTitle.text = pick(entry, "title")
    m.detailDesc.text = pick(entry, "desc")
    m.detailStatus.text = ""
end sub

'──────────────────────── chrome/i18n ────────────────────────

sub renderChrome()
    s = currentStrings()
    m.wifiLabel.text = s.netName
    m.netcardName.text = s.netName
    m.netcardStatus.text = s.netStatus
    m.sectionLabel.text = s.sectionModules
    m.hintLabel.text = s.hint
    m.greetingLabel.text = greetingForHour(currentHour())
    m.heroSubLabel.text = s.heroSub
end sub

sub toggleLanguage()
    if m.lang = "pt"
        m.lang = "en"
    else
        m.lang = "pt"
    end if
    saveLang()
    buildRail()
    renderChrome()
    updateFocus()
    print "[Home] language -> " + m.lang
end sub

'──────────────────────── ativação ────────────────────────

sub activateModule()
    entry = m.modules[m.focusIndex]
    s = currentStrings()
    if entry.id = "settings"
        toggleLanguage()
        m.detailStatus.text = s.statusLangSet
    else
        m.detailStatus.text = s.statusSoon
    end if
    print "[Focus] activate " + entry.id
end sub

'──────────────────────── relógio ────────────────────────

sub onClockTick()
    updateClock()
end sub

sub updateClock()
    s = currentStrings()
    d = CreateObject("roDateTime")
    d.ToLocalTime()
    h = d.GetHours()
    minute = d.GetMinutes()

    if s.clock24h
        m.clockLabel.text = gxPad2(h) + ":" + gxPad2(minute)
    else
        h12 = h mod 12
        if h12 = 0 then h12 = 12
        suffix = " AM"
        if h >= 12 then suffix = " PM"
        m.clockLabel.text = stri(h12).trim() + ":" + gxPad2(minute) + suffix
    end if

    m.greetingLabel.text = greetingForHour(h)
end sub

function greetingForHour(h as integer) as string
    s = currentStrings()
    if h < 5
        return s.greetingEvening
    else if h < 12
        return s.greetingMorning
    else if h < 18
        return s.greetingAfternoon
    else
        return s.greetingEvening
    end if
end function

function currentHour() as integer
    d = CreateObject("roDateTime")
    d.ToLocalTime()
    return d.GetHours()
end function

'──────────────────────── feed ────────────────────────

sub startFeed()
    m.feedTask = CreateObject("roSGNode", "FeedTask")
    m.feedTask.uri = m.cfg.feedUrl
    m.feedTask.observeField("content", "onFeedContent")
    m.feedTask.control = "RUN"
    print "[Home] feed task started: " + m.cfg.feedUrl
end sub

sub onFeedContent()
    content = m.feedTask.content
    if content <> invalid and content.ok
        print "[Feed] ok — " + stri(content.modules.Count()).trim() + " modules"
        m.modules = content.modules
        m.offlineLabel.visible = false
        buildRail()
        updateFocus()
    else
        if content = invalid
            reason = "invalid result"
        else
            reason = content.error
        end if
        print "[Feed] failed: " + reason + " — keeping local modules"
        m.offlineLabel.visible = true
        m.offlineLabel.text = currentStrings().offline
    end if
end sub

'──────────────────────── helpers ────────────────────────

function currentStrings() as object
    if m.lang = "en" then return m.strings.en
    return m.strings.pt
end function

' Escolhe title_pt/desc_pt ou title_en/desc_en do módulo.
function pick(entry as object, base as string) as string
    key = base + "_" + m.lang
    value = entry.Lookup(key)
    if value <> invalid then return value
    return entry.Lookup(base + "_pt")
end function

function badgeTextFor(entry as object) as string
    if m.lang = "en"
        if entry.badge = "now" then return "Live now"
        return "Coming soon"
    else
        if entry.badge = "now" then return "Agora"
        return "Em breve"
    end if
end function

'──────────────────────── registro ────────────────────────

function loadLang() as string
    sec = CreateObject("roRegistrySection", m.cfg.registrySection)
    stored = sec.Read("lang")
    if stored = "en" then return "en"
    return "pt"
end function

sub saveLang()
    sec = CreateObject("roRegistrySection", m.cfg.registrySection)
    sec.Write("lang", m.lang)
    sec.Flush()
end sub

'──────────────────────── input ────────────────────────

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    count = m.modules.Count()

    if key = "left"
        m.focusIndex = (m.focusIndex + count - 1) mod count
        updateFocus()
        return true
    else if key = "right"
        m.focusIndex = (m.focusIndex + 1) mod count
        updateFocus()
        return true
    else if key = "OK"
        activateModule()
        return true
    else if key = "options"
        toggleLanguage()
        return true
    end if

    return false
end function
