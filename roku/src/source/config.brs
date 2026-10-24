'*************************************************************
'** GalaxyOS — constantes e strings (uma fonte, um lugar)
'** Escopo global: importado por HomeScene.xml via script uri.
'*************************************************************

' Paleta Deep Space (espelha prototype/css/style.css :root).
' SceneGraph usa 0xRRGGBBAA.
function gxPalette() as object
    return {
        bg:       "0x05070FFF"
        text:     "0xEDF1F9FF"
        textDim:  "0x98A3BEFF"
        accent:   "0x6EE7FFFF"
        accent2:  "0x8B7CFFFF"
        onAccent: "0x04121CFF"
        ok:       "0x4ADE80FF"
        warn:     "0xFBC75CFF"
        panel:    "0x0D1221E6"
        panel2:   "0x0D1221F2"
        line:     "0xFFFFFF1C"
        accentSoft: "0x6EE7FF21"
        badgeSoon: "0x8B7CFF26"
        badgeNow:  "0x6EE7FF21"
    }
end function

function gxConfig() as object
    return {
        version: "Fase 1 · v0.1"
        feedUrl: "https://lucasgabrieldevgg.github.io/galaxyos/feeds/modules.json"
        registrySection: "galaxyos"
        maxModules: 8
        maxTitleLen: 80
        maxDescLen: 160
        feedTimeoutMs: 20000
        clockTickSeconds: 30
    }
end function

' Chrome da UI bilíngue (mesmas strings do protótipo web).
function gxStrings() as object
    return {
        pt: {
            greetingMorning: "Bom dia,"
            greetingAfternoon: "Boa tarde,"
            greetingEvening: "Boa noite,"
            heroSub: "Bem-vindo ao seu universo na TV."
            netName: "GalaxyNet 5G"
            netStatus: "Conectado · Internet OK"
            sectionModules: "GalaxyOS"
            hint: "Setas: navegar · OK: abrir · *: idioma · Back: sair"
            offline: "Sem conexão — exibindo módulos locais"
            statusSoon: "Módulo previsto para a próxima fase."
            statusLangSet: "Idioma: Português"
            clockSuffixAm: ""
            clock24h: true
        }
        en: {
            greetingMorning: "Good morning,"
            greetingAfternoon: "Good afternoon,"
            greetingEvening: "Good evening,"
            heroSub: "Welcome to your universe on the TV."
            netName: "GalaxyNet 5G"
            netStatus: "Connected · Internet OK"
            sectionModules: "GalaxyOS"
            hint: "Arrows: navigate · OK: open · *: language · Back: exit"
            offline: "No connection — showing local modules"
            statusSoon: "Module planned for the next phase."
            statusLangSet: "Language: English"
            clockSuffixAm: ""
            clock24h: false
        }
    }
end function

' Módulos de fallback (off-line) — mesmo conteúdo do feed.
function gxFallbackModules() as object
    return [
        { id: "games",    title_pt: "Jogos",        title_en: "Games",    desc_pt: "Biblioteca, minigames e recordes.",       desc_en: "Library, mini-games and high scores.",   badge: "soon" }
        { id: "web",      title_pt: "Web Hub",      title_en: "Web Hub",  desc_pt: "Conteúdo e serviços via GalaxyOS Hub.",   desc_en: "Content and services via the GalaxyOS Hub.", badge: "soon" }
        { id: "connect",  title_pt: "Connect",      title_en: "Connect",  desc_pt: "PC na TV, celular no controle.",           desc_en: "PC on the TV, phone as the remote.",     badge: "soon" }
        { id: "settings", title_pt: "Configurações", title_en: "Settings", desc_pt: "Idioma, aparência e informações.",         desc_en: "Language, appearance and info.",         badge: "now" }
    ]
end function

' Zero-pad de 2 dígitos para o relógio (stri() vem com espaço à esquerda).
function gxPad2(n as integer) as string
    s = stri(n).trim()
    if n < 10 then return "0" + s
    return s
end function
