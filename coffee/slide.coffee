clsMarkdown = require './classes/mds_markdown'
ipc         = require('electron').ipcRenderer
Path        = require 'path'

resolvePathFromMarp = (path = './') -> Path.resolve(__dirname, '../', path)

document.addEventListener 'DOMContentLoaded', ->
  $ = window.jQuery = window.$ = require('jquery')

  do ($) ->
    # First, resolve Marp resources path
    $("[data-marp-path-resolver]").each ->
      for target in $(@).attr('data-marp-path-resolver').split(/\s+/)
        $(@).attr(target, resolvePathFromMarp($(@).attr(target)))

    Markdown = new clsMarkdown({ afterRender: clsMarkdown.generateAfterRender($) })

    setStyle = (identifier, css) ->
      id  = "mds-#{identifier}Style"
      elm = $("##{id}")
      elm = $("<style id=\"#{id}\"></style>").appendTo(document.head) if elm.length <= 0
      elm.text(css)

    getCSSvar = (prop) -> document.defaultView.getComputedStyle(document.body).getPropertyValue(prop)

    getSlideSize = ->
      size =
        w: +getCSSvar '--slide-width'
        h: +getCSSvar '--slide-height'

      size.ratio = size.w / size.h
      size

    currentPage = 1

    applyCurrentPage = (page) ->
      if page >= 0 && page <= $('#markdown > .slide_wrapper').length
        currentPage = page
        $('.slide_wrapper:first-child').css('margin-left', '-' + (page - 1) * 100 + '%')

    prevPage = ->
      applyCurrentPage(currentPage - 1)

    nextPage = ->
      applyCurrentPage(currentPage + 1)

    render = (md) ->
      $('#markdown').html(md.parsed)

      applyCurrentPage(currentPage)
      ipc.sendToHost 'rendered', md
      ipc.sendToHost 'rulerChanged', md.rulers if md.rulerChanged

    setImageDirectory = (dir) -> $('head > base').attr('href', dir || './')

    ipc.on 'render', (e, md) -> render(Markdown.parse(md))
    ipc.on 'currentPage', (e, page) -> applyCurrentPage page
    ipc.on 'setClass', (e, classes) -> $('body').attr 'class', classes
    ipc.on 'setImageDirectory', (e, dir) -> setImageDirectory(dir)

    ipc.on 'increaseFontSize', =>
      size = parseInt($('.markdown-body').css('font-size'))
      @originalSize = size unless @originalSize
      if size <= 40
        $('.markdown-body').css('font-size', size + 2 + 'px')

    ipc.on 'decreaseFontSize', =>
      size = parseInt($('.markdown-body').css('font-size'))
      @originalSize = size unless @originalSize
      if size >= 14
        $('.markdown-body').css('font-size', size - 2 + 'px')

    ipc.on 'originalFontSize', =>
      $('.markdown-body').css('font-size', @originalSize + 'px')

    # Initialize
    $(document).on 'click', 'a', (e) ->
      e.preventDefault()
      ipc.sendToHost 'linkTo', $(e.currentTarget).attr('href')

    $(document)
      .on 'dragover',  -> false
      .on 'dragleave', -> false
      .on 'dragend',   -> false
      .on 'drop',      -> false
      .on 'keyup', (e) =>
        prevPage() if e.which == 33 or e.which == 37 or e.which == 38
        nextPage() if e.which == 32 or e.which == 34 or e.which == 39 or e.which == 40
