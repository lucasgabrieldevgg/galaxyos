'*************************************************************
'** GalaxyOS — validação do feed (o feed é entrada NÃO
'** confiável: valida tipo, tamanho e forma antes de render).
'** Função pura: sem I/O, sem nós — testável fora do device.
'** Retorna array normalizado ou invalid.
'*************************************************************

function validateModules(json as dynamic) as dynamic
    if json = invalid then return invalid
    if type(json) <> "roAssociativeArray" then return invalid

    raw = json.Lookup("modules")
    if raw = invalid then return invalid
    if type(raw) <> "roArray" then return invalid

    cfg = gxConfig()
    count = raw.Count()
    if count = 0 or count > cfg.maxModules then return invalid

    ' Whitelist de ids conhecidos do canal (feed não inventa módulos)
    allowedIds = { games: true, web: true, connect: true, settings: true }

    out = []
    for each item in raw
        if item = invalid then return invalid
        if type(item) <> "roAssociativeArray" then return invalid

        id = item.Lookup("id")
        if type(id) <> "String" then return invalid
        if not allowedIds.Lookup(id) then return invalid

        titlePt = item.Lookup("title_pt")
        titleEn = item.Lookup("title_en")
        descPt = item.Lookup("desc_pt")
        descEn = item.Lookup("desc_en")
        if type(titlePt) <> "String" or type(titleEn) <> "String" then return invalid
        if type(descPt) <> "String" or type(descEn) <> "String" then return invalid

        if Len(titlePt) = 0 or Len(titlePt) > cfg.maxTitleLen then return invalid
        if Len(titleEn) = 0 or Len(titleEn) > cfg.maxTitleLen then return invalid
        if Len(descPt) = 0 or Len(descPt) > cfg.maxDescLen then return invalid
        if Len(descEn) = 0 or Len(descEn) > cfg.maxDescLen then return invalid

        badge = item.Lookup("badge")
        if badge = invalid or type(badge) <> "String"
            badge = "soon"
        else if badge <> "soon" and badge <> "now"
            badge = "soon"
        end if

        out.Push({ id: id, title_pt: titlePt, title_en: titleEn, desc_pt: descPt, desc_en: descEn, badge: badge })
    end for

    return out
end function

'*************************************************************
'** Meta do feed (ADR-0006 — atualização de conteúdo).
'** Informativo: NUNCA rejeita o feed, só sanitiza o que vai
'** para a UI (versão do conteúdo e data da última edição).
'** Pura e testável no host (tests/feed-contract.js).
'*************************************************************

function validateMeta(json as dynamic) as object
    meta = { version: 0, updated: "" }
    if json = invalid then return meta
    if type(json) <> "roAssociativeArray" then return meta

    raw = json.Lookup("meta")
    if raw = invalid then return meta
    if type(raw) <> "roAssociativeArray" then return meta

    v = raw.Lookup("version")
    if v <> invalid
        tv = type(v)
        if tv = "Integer" or tv = "LongInteger"
            if v > 0 and v <= 99999
                meta.version = v
            end if
        end if
    end if

    u = raw.Lookup("updated")
    if type(u) = "String"
        if Len(u) > 0 and Len(u) <= 24
            meta.updated = u
        end if
    end if

    return meta
end function
