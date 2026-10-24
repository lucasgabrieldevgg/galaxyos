'*************************************************************
'** GalaxyOS — FeedTask
'** Busca o JSON do Hub (GitHub Pages hoje) fora do render
'** thread, valida e devolve pelo campo content.
'*************************************************************

sub init()
    m.top.functionName = "fetchModules"
end sub

sub fetchModules()
    cfg = gxConfig()
    result = { ok: false, modules: invalid, error: "unknown" }

    uri = m.top.uri
    if uri = invalid or Len(uri) = 0
        result.error = "no-uri"
        m.top.content = result
        return
    end if

    xfer = CreateObject("roUrlTransfer")
    xfer.SetUrl(uri)

    port = CreateObject("roMessagePort")
    xfer.SetMessagePort(port)

    started = xfer.AsyncGetToString()
    if not started
        result.error = "request-not-started"
        m.top.content = result
        return
    end if

    msg = wait(cfg.feedTimeoutMs, port)
    if msg = invalid
        result.error = "timeout"
        m.top.content = result
        return
    end if

    if type(msg) <> "roUrlEvent"
        result.error = "unexpected-event"
        m.top.content = result
        return
    end if

    code = msg.GetResponseCode()
    if code <> 200
        result.error = "http-" + stri(code).trim()
        m.top.content = result
        return
    end if

    body = msg.GetString()
    if body = invalid or Len(body) = 0
        result.error = "empty-body"
        m.top.content = result
        return
    end if

    json = ParseJson(body)
    if json = invalid
        result.error = "bad-json"
        m.top.content = result
        return
    end if

    modules = validateModules(json)
    if modules = invalid
        result.error = "invalid-feed"
        m.top.content = result
        return
    end if

    result.ok = true
    result.modules = modules
    result.error = ""
    m.top.content = result
end sub
