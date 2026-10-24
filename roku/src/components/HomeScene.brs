'*************************************************************
'** GalaxyOS — HomeScene (Fase 1)
'** Launcher home Deep Space: saudação por hora, relógio,
'** card de rede, rail de módulos (foco gerenciado pela cena
'** — ADR-0004) e painel de detalhe. Feed via Task (fallback
'** offline embutido). Idioma PT/EN via * (registro).
'** Atualização de conteúdo (ADR-0006): busca ao abrir,
'** re-checa a cada 15 min e OK em Configurações busca agora.
'*************************************************************

sub init()
    m.cfg = gxConfig()
    m.strings = gxStrings()

    m.lang = loadLang()
    m.modules = gxFallbackModules()
    m.focusIndex = 0

    ' estado do conteúdo (atualização OTA — ADR-0006)
    m.contentVersion = 0
    m.contentUpdated = ""
    m.hasContent = false
    m.checkingUpdates = false

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
    m.logoLabel = m.top.findNode("logoLabel")
    m.toastGroup = m.top.findNode("toastGroup")
    m.toastLabel = m.top.findNode("toastLabel")

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
    m.toastLabel.font.size = 28

    ' relógio: tick a cada 30s
    m.clockTimer = CreateObject("roSGNode", "Timer")
    m.clockTimer.duration = m.cfg.clockTickSeconds
    m.clockTimer.repeat = true
    m.clockTimer.observeField("fire", "onClockTick")
    m.clockTimer.control = "start"

    ' toast: esconde sozinho depois de alguns segundos
    m.toastTimer = CreateObject("roSGNode", "Timer")
    m.toastTimer.duration = m.cfg.toastSeconds
    m.toastTimer.observeField("fire", "onToastTick")

    ' conteúdo: re-checa o feed periodicamente (atualiza sem reinstalar)
    m.feedTimer = CreateObject("roSGNode", "Timer")
    m.feedTimer.duration = m.cfg.feedRefreshSeconds
    m.feedTimer.repeat = true
    m.feedTimer.observeField("fire", "onFeedRefresh")
    m.feedTimer.control = "start"

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
    if entry.id = "settings"
        m.detailStatus.text = settingsInfoLine()
    else
        m.detailStatus.text = ""
    end if
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
        ' OK em Configurações = buscar atualização de conteúdo agora
        m.checkingUpdates = true
        m.detailStatus.text = s.statusChecking
        startFeed()
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

'──────────────────────── feed (conteúdo OTA) ────────────────────────

sub startFeed()
    if m.feedTask = invalid
        m.feedTask = CreateObject("roSGNode", "FeedTask")
        m.feedTask.observeField("content", "onFeedContent")
    end if
    ' cache-bust: o GitHub Pages cacheia por 10 min
    m.feedTask.uri = m.cfg.feedUrl + "?t=" + stri(CreateObject("roDateTime").AsSeconds()).trim()
    m.feedTask.control = "RUN"
    print "[Home] feed fetch: " + m.feedTask.uri
end sub

sub onFeedRefresh()
    print "[Feed] auto refresh"
    startFeed()
end sub

sub applyModules(modules as object, meta as object)
    m.modules = modules
    if meta <> invalid
        m.contentVersion = meta.version
        m.contentUpdated = meta.updated
    end if
    ' clamp: o feed pode vir com menos módulos do que o foco atual
    if m.focusIndex >= m.modules.Count() then m.focusIndex = m.modules.Count() - 1
    if m.focusIndex < 0 then m.focusIndex = 0
    buildRail()
    updateFocus()
end sub

sub onFeedContent()
    content = m.feedTask.content
    if content = invalid then content = { ok: false, error: "invalid result" }
    s = currentStrings()

    if content.ok
        meta = content.meta
        if meta = invalid then meta = { version: 0, updated: "" }
        print "[Feed] ok — " + stri(content.modules.Count()).trim() + " modules (v" + stri(meta.version).trim() + ")"
        m.offlineLabel.visible = false

        if m.hasContent and meta.version > m.contentVersion
            applyModules(content.modules, meta)
            showToast(s.toastContentUpdated)
            if m.checkingUpdates then m.detailStatus.text = s.statusContentUpdated
            print "[Feed] conteúdo atualizado para v" + stri(meta.version).trim()
        else
            applyModules(content.modules, meta)
            if m.checkingUpdates then m.detailStatus.text = s.statusUpToDate
        end if

        m.hasContent = true
    else
        print "[Feed] failed: " + content.error + " — keeping current modules"
        if not m.hasContent
            m.offlineLabel.visible = true
            m.offlineLabel.text = s.offline
        end if
        if m.checkingUpdates then m.detailStatus.text = s.statusCheckFailed
    end if

    m.checkingUpdates = false
end sub

'──────────────────────── toast ────────────────────────

sub showToast(msg as string)
    m.toastLabel.text = msg
    m.toastGroup.visible = true
    m.toastTimer.duration = m.cfg.toastSeconds
    m.toastTimer.control = "start"
end sub

sub onToastTick()
    m.toastGroup.visible = false
end sub

function settingsInfoLine() as string
    s = currentStrings()
    line = "GalaxyOS " + m.cfg.version + " · " + s.infoContent + " v" + stri(m.contentVersion).trim()
    if m.contentUpdated <> ""
        line = line + " · " + m.contentUpdated
    end if
    return line
end function

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
