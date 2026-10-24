.pragma library

function words(text) {
  var trimmed = String(text || "").replace(/^\s+|\s+$/g, "")
  if (trimmed === "") return 0
  return trimmed.split(/\s+/).length
}

function payload(raw) {
  var text = String(raw || "")
  var nl = text.indexOf("\n")
  var head = nl === -1 ? text : text.slice(0, nl)
  var marker = "omarchy-uniform\t"
  if (head.indexOf(marker) === 0)
    return { kind: head.slice(marker.length), body: nl === -1 ? "" : text.slice(nl + 1) }
  return { kind: "plain", body: text }
}

function decodeEntities(text) {
  return String(text)
    .replace(/&#x([0-9a-f]+);/gi, function(_, hex) {
      var code = parseInt(hex, 16)
      return isFinite(code) ? String.fromCodePoint(code) : _
    })
    .replace(/&#(\d+);/g, function(_, dec) {
      var code = parseInt(dec, 10)
      return isFinite(code) ? String.fromCodePoint(code) : _
    })
    .replace(/&nbsp;/gi, " ")
    .replace(/&quot;/gi, "\"")
    .replace(/&apos;|&#39;/gi, "'")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&amp;/gi, "&")
}

function stripHtml(html) {
  return decodeEntities(String(html)
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/<style[\s\S]*?<\/style>/gi, "")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/(p|div|h[1-6]|li|tr|blockquote|pre|section|article)>/gi, "\n")
    .replace(/<li[^>]*>/gi, "- ")
    .replace(/<[^>]+>/g, ""))
}

function tidy(text) {
  return String(text)
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .replace(/[\u00a0\u1680\u2000-\u200a\u202f\u205f\u3000]/g, " ")
    .replace(/[\u00ad\u200b\u200e\u200f\u202a-\u202e\u2060\u2066-\u2069\ufeff]/g, "")
    .split("\n")
    .map(function(line) { return line.replace(/[ \t]+$/g, "") })
    .join("\n")
    .replace(/\n{3,}/g, "\n\n")
    .replace(/^\n+|\n+$/g, "")
}

function uniformPlain(text) {
  return tidy(text)
}

function uniformHtml(html) {
  return tidy(stripHtml(html))
}
