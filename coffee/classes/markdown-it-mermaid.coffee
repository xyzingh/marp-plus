mermaid = require 'mermaid'
id = 0

mermaidChart = (code) ->
  id += 1
  elId = 'mermaid-' + id
  el = $("<div id='#{elId}'></div>").text(code)
  init = ->
    el = $('#' + elId)
    if not el.length
      setTimeout init, 0
      return
    try (require 'mermaid').init(undefined, el)
    catch e
      el.find('svg').remove()
      $("<pre>#{e.message}</pre>").appendTo(el)
  setTimeout init, 0
  return el.prop("outerHTML")

module.exports = (md) ->
  md.mermaid = mermaid
  mermaid.initialize
    theme: 'neutral'
    gantt: 
      axisFormatter:
        - ['%Y-%m-%d', (d) -> d.getDay() == 1]

  temp = md.renderer.rules.fence.bind md.renderer.rules
  md.renderer.rules.fence = (tokens, idx, options, env, slf) ->
    token = tokens[idx]
    code = token.content.trim()
    if token.info == 'mermaid'
      mermaidChart code
    else
      temp tokens, idx, options, env, slf