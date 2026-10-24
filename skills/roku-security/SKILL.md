---
name: roku-security
description: "Defensive application security, adapted for the Roku ecosystem: a channel shipped as an extractable package, a web Hub the whole internet can reach, ECP on the LAN, a phone pretending to be a remote, and a Linux companion receiving commands. Adapted from lucasgabrieldevgg/security v1.0.0 (MIT). Three modes: WRITE-SECURE (name the trust boundary before writing the feature — the feed is untrusted input, the package is public code, the LAN is hostile), AUDIT (category scan against the Roku top-10 that AI-built channels actually ship: open proxy Hub/SSRF via adapters, weak pairing codes, secrets in the package or roRegistry, unvalidated feed fields driving UI, missing rate limits, plaintext LAN transport, unpinned ropm deps), HACK-ME (prove findings against the user's OWN Hub and OWN TV with curl/ncat on the LAN, patch, re-verify, sweep the class). Includes the platform rule with teeth: apps must NOT emit ECP commands from inside the channel — Static Analysis blocks publishing for it. Use whenever writing or reviewing channel code, Hub endpoints, pairing flows, companion services, feeds, or anything that touches a TV, a phone and a PC at once."
version: 1.0.0
license: MIT — adaptation of lucasgabrieldevgg/security (MIT). Upstream licenses: see original ATTRIBUTION.md.
---

# roku-security — channels, hubs and companions that survive contact with the network

A Roku product is not one app. It is a **triangle**: a TV running your closed-but-extractable package, a Hub on the public internet, and companion devices (phone, PC) sending commands across a LAN that other people's devices also live on. Each edge of that triangle is a trust boundary, and the generic web-app threat model misses most of them.

The contract carries over unchanged — **never trust the client, deny by default, prove it or say you didn't, match paranoia to blast radius, fix the class not the instance, report like a defender** — and gets Roku teeth:

## Roku-specific hard rules

1. **The channel package is public code.** Anything compiled into it (API keys, Hub tokens, "hidden" URLs, dev endpoints) must be assumed extracted on day one. Secrets live server-side in the Hub; the channel authenticates as a device, it does not hold master keys.
2. **The channel never emits ECP.** Roku's Static Analysis **blocks publishing** of apps containing code that issues ECP commands (official docs, external-control-api). This is not a style rule — it is a cert wall. Incoming ECP (deep links, voice) is fine; outgoing ECP from inside the channel is forbidden. Phone-as-remote must go through the Hub, not through ECP spam from a published companion.
3. **The feed is untrusted input driving the UI.** Every field the Hub (or anything the Hub proxies) delivers — titles, URLs, deep-link parameters, image paths — is validated for type, length and shape before it renders or opens. A feed field is a form input that happens to arrive as JSON.
4. **The LAN is hostile.** ECP on port 8060 accepts keypresss from any device on the network when "Control by mobile apps" is enabled; the debug console on :8085 leaks logs to anyone who can telnet. Design as if a roommate's infected laptop is on the same subnet — because on real home networks, it sometimes is.
5. **roRegistry is not a vault.** On-device storage is readable in dev workflows (ECP `query/registry` in Developer Mode) and survives re-sideloads. Persist preferences, not credentials; if a token must live there, it is short-lived, scoped, and revocable.
6. **Adapters are not a proxy.** The Web Hub fetches from an **allowlist of specific origins** with specific response shapes. A generic "fetch any URL the client asks for" endpoint is an SSRF botnet in waiting — the first thing an attacker does with a public proxy is pivot to internal networks or serve malware through your domain.

## Trust boundaries (name one out loud before writing any feature)

| Boundary | Who controls what | The question to answer |
| --- | --- | --- |
| Internet → Hub | anyone on earth hits your endpoints | auth? rate limit? input size caps? |
| Hub → Channel (the feed) | a compromised Hub or MITM feeds the TV | schema-validated? TLS? image URLs constrained to hosts you allow? |
| Channel → Hub | the extractable package, replayable | does it hold secrets? is the device token scoped+revocable? |
| Phone → Hub → TV | the phone is a browser the user half-controls | pairing is proof-of-presence, not proof of identity — what can a paired phone actually do? |
| Companion (PC) ↔ TV | commands crossing the LAN | authenticated? replayable? plaintext? |
| LAN → TV (ECP :8060) | anyone on the network | assumed hostile; document it in the threat model, don't fight the platform |

## The Roku top 10 (what AI-built Roku ecosystems actually ship)

1. **Open-proxy Hub / SSRF** — an adapter endpoint that fetches user-supplied URLs. Fix: origin allowlist, response schema, no redirects to internal ranges, egress from a separate worker if possible.
2. **Weak pairing** — a 4-digit code with no rate limit lives ~10 minutes under a script. Fix: 6+ chars, attempt limiting, short expiry, per-TV scoping.
3. **Secrets in the package** — keys compiled into the channel. Fix: there are none, by construction; the channel uses device-identity flows.
4. **Unvalidated feed driving UI** — oversized strings, `file://`-ish or cross-origin image URLs, deep-link params passed straight to navigation. Fix: validate-then-render, cap lengths, constrain URL hosts.
5. **No rate limits on the Hub** — a public JSON API someone will find and hammer (cost, DoS on your quota). Fix: per-IP and per-token budgets on every route.
6. **Plaintext LAN transport** — companion and debug traffic in clear HTTP on a hostile network. Fix: TLS for anything that leaves localhost; mTLS or tokens for the companion service.
7. **Command injection surface on the companion** — the PC service that "runs what the phone says" (open app, send keys). Fix: fixed verb set, no shell-outs, no string-to-command, allowlist of controllable apps.
8. **Stale/leaky debug surface** — verbose logs printing tokens/URLs/PII; debug console left useful but noisy. Fix: log levels, redaction helper used everywhere from day one.
9. **Session fixation across devices** — pairing tokens that never expire, TV tokens shared across users. Fix: rotation, revocation, per-user scoping.
10. **Unpinned/unaudited supply chain** — `ropm` deps and Hub npm deps floating. Fix: lockfiles committed, `npm audit`/`bslint` in CI-lite before every release.

## Three modes (unchanged spine, Roku surface)

| Mode | When | What it does |
| --- | --- | --- |
| **Write-secure** (default) | while writing any feature that crosses a boundary above | name the boundary, apply the secure default, 30-second adversarial pass ("what does the feed/phone/LAN/attacker control here?") before calling it done |
| **Audit** | existing channel/Hub/companion code | inventory surfaces (routes, feed fields, registry writes, ECP-adjacent code, companion verbs) → top-10 scan with false-positive gates → severity-ranked report with file:line and before/after |
| **Hack-me** | the user's OWN stack, on their OWN LAN/host | authorized probes: curl the Hub from a "stranger" vantage, replay a pairing code, feed the channel a hostile JSON from a local server, ncat the TV — then patch, **re-verify the exact probe now fails**, and sweep for the same class everywhere |

## Pre-certification / pre-deploy gate

- [ ] `grep` the repo: no `curl`/ECP-emitting code inside channel sources (Static Analysis will block; your CI should catch it first).
- [ ] No secrets in package sources or git history; the Hub serves everything secret.
- [ ] Hub: every route has auth or an annotated public reason; rate limits on; input caps on; adapter allowlist enforced.
- [ ] Pairing: expiry, attempt limits, per-TV scoping verified by an actual replay probe.
- [ ] Feed: schema validation rejects a malformed fixture (test it with a hostile JSON fixture in the repo).
- [ ] Companion: verb allowlist, no shell-outs from phone input, TLS off-localhost.
- [ ] Logs: redaction helper in use; a grep for tokens in logs comes back empty.
- [ ] Official **Static Analysis tool** run clean before any Store submission.

## Scope & safety (unchanged, repeated because it matters)

This skill secures the **user's own** channel, Hub, companion and TV. Hack-me probes run against the user's own devices and localhost only, are non-destructive, and never flood. The TV on the LAN is the user's TV. It does not target third-party devices found by SSDP, other people's networks, or anything the user doesn't own — including "that other Roku in the house" without asking.
