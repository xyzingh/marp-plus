mermaid = require 'mermaid'

mermaidChart = (code) ->
  try
    el = $("<div>#{code}</div>").appendTo($('body'))
    try (require 'mermaid').init(undefined, el)
    html = "<div class='mermaid'>#{el.html()}</div>"
    el.remove()
    return html
  catch e
    "<pre>#{e.str}</pre>"

module.exports = (md) ->
  md.mermaid = mermaid
  mermaid.loadPreferences = (preferenceStore) ->
    mermaidTheme = (preferenceStore.get 'mermaid-theme') or 'default'
    ganttAxisFormat = (preferenceStore.get 'gantt-axis-format') or '%Y-%m-%d'

    mermaid.initialize
      theme: mermaidTheme
      gantt: 
        axisFormatter:
          - [ganttAxisFormat, (d) -> d.getDay() == 1]

    return
      'mermaid-theme': mermaidTheme
      'gantt-axis-format': ganttAxisFormat

  temp = md.renderer.rules.fence.bind md.renderer.rules
  md.renderer.rules.fence = (tokens, idx, options, env, slf) ->
    token = tokens[idx]
    code = token.content.trim()
    if token.info == 'mermaid'
      mermaidChart code
    else
      temp tokens, idx, options, env, slf