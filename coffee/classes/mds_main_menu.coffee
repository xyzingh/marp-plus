{app, dialog, shell}  = require 'electron'
extend                = require 'extend'
path                  = require 'path'
MdsMenu               = require './mds_menu'
MdsFileHistory        = require './mds_file_history'

module.exports = class MdsMainMenu
  states: {}
  window: null
  menu: null

  @useAppMenu: process.platform is 'darwin'
  @instances: new Map
  @currentMenuId: null

  constructor: (@states) ->
    @mdsWindow = require './mds_window'
    @window    = @states?.window || null
    @window_id = @window?.id || null

    MdsMainMenu.instances.set @window_id, @
    @listenWindow()
    @updateMenu()

  listenWindow: () =>
    return false unless @window?

    resetAppMenu = ->
      MdsMainMenu.currentMenuId = null
      MdsMainMenu.instances.get(null).applyMenu() if MdsMainMenu.useAppMenu

    @window.on 'focus', =>
      MdsMainMenu.currentMenuId = @window_id
      @applyMenu() if MdsMainMenu.useAppMenu

    @window.on 'blur', resetAppMenu

    @window.on 'closed', =>
      MdsMainMenu.instances.delete(@window_id)
      resetAppMenu()

  applyMenu: () =>
    if MdsMainMenu.useAppMenu
      if @window_id == MdsMainMenu.currentMenuId
        @menu.object.setAppMenu(@menu.options)
    else
      @menu.object.setMenu(@window, @menu.options) if @window?

  @updateMenuToAll: () =>
    @instances.forEach (m) -> m.updateMenu()

  updateMenu: () =>
    MdsWindow = @mdsWindow
    @menu =
      object: new MdsMenu [
        {
          label: app.getName()
          platform: 'darwin'
          submenu: [
            { label: '隐藏', accelerator: 'Command+H', role: 'hide' }
            { label: '隐藏其它', accelerator: 'Command+Alt+H', role: 'hideothers' }
            { label: '显示全部', role: 'unhide' }
            { type: 'separator' }
            { label: '退出', role: 'quit' }
          ]
        }
        {
          label: '文件'
          submenu: [
            { label: '新建', accelerator: 'CmdOrCtrl+N', click: -> new MdsWindow }
            { type: 'separator' }
            {
              label: '打开...'
              accelerator: 'CmdOrCtrl+O'
              click: (item, w) ->
                args = [
                  {
                    title: '打开'
                    filters: [
                      { name: 'Markdown 文件', extensions: ['md', 'mdown'] }
                      { name: '文本文件', extensions: ['txt'] }
                      { name: '所有文件', extensions: ['*'] }
                    ]
                    properties: ['openFile', 'createDirectory']
                  }
                  (fnames) ->
                    return unless fnames?
                    MdsWindow.loadFromFile fnames[0], w?.mdsWindow
                ]
                args.unshift w.mdsWindow.browserWindow if w?.mdsWindow?.browserWindow?
                dialog.showOpenDialog.apply @, args
            }
            {
              label: '打开最近文件'
              submenu: [{ replacement: 'fileHistory' }]
            }
            { label: '存储', enabled: @window?, accelerator: 'CmdOrCtrl+S', click: => @window.mdsWindow.trigger 'save' }
            { label: '另存为...', enabled: @window?, click: => @window.mdsWindow.trigger 'saveAs' }
            { type: 'separator', platform: '!darwin' }
            { label: '关闭', role: 'close', platform: '!darwin' }
          ]
        }
        {
          label: '编辑'
          submenu: [
            {
              label: '撤销'
              enabled: @window?
              accelerator: 'CmdOrCtrl+Z'
              click: => @window.mdsWindow.send 'editCommand', 'undo' unless @window.mdsWindow.freeze
            }
            {
              label: '重做'
              enabled: @window?
              accelerator: do -> if process.platform is 'win32' then 'Control+Y' else 'Shift+CmdOrCtrl+Z'
              click: => @window.mdsWindow.send 'editCommand', 'redo' unless @window.mdsWindow.freeze
            }
            { type: 'separator' }
            { label: '剪切', accelerator: 'CmdOrCtrl+X', role: 'cut' }
            { label: '拷贝', accelerator: 'CmdOrCtrl+C', role: 'copy' }
            { label: '粘贴', accelerator: 'CmdOrCtrl+V', role: 'paste' }
            { label: '删除', role: 'delete' }
            {
              label: '全选'
              enabled: @window?
              accelerator: 'CmdOrCtrl+A'
              click: => @window.mdsWindow.send 'editCommand', 'selectAll' unless @window.mdsWindow.freeze
            }
          ]
        }
        {
          label: '显示'
          submenu: [
            {
              label: '放大'
              enabled: @window?
              accelerator: 'CmdOrCtrl+='
              click: => @window.mdsWindow.trigger 'increaseFontSize'
            }
            {
              label: '缩小'
              enabled: @window?
              accelerator: 'CmdOrCtrl+-'
              click: => @window.mdsWindow.trigger 'decreaseFontSize'
            }
            {
              label: '原始大小'
              enabled: @window?
              accelerator: 'CmdOrCtrl+0'
              click: => @window.mdsWindow.trigger 'originalFontSize'
            }
            { type: 'separator' }
            {
              label: '切换编辑栏'
              enabled: @window?
              accelerator: 'Esc'
              click: -> # 什么也不做，让 index 层来监听
            }
            { type: 'separator' }
            {
              label: '全屏'
              accelerator: do -> if process.platform == 'darwin' then 'Ctrl+Command+F' else 'F11'
              role: 'togglefullscreen'
            }
          ]
        }
        {
          label: '窗口'
          role: 'window'
          platform: 'darwin'
          submenu: [
            { label: '最小化', accelerator: 'CmdOrCtrl+M', role: 'minimize' }
            { label: '关闭', accelerator: 'CmdOrCtrl+W', role: 'close' }
            { type: 'separator' }
            { label: '前置全部窗口', role: 'front' }
          ]
        }
        {
          label: '开发'
          submenu: [
            { label: '切换主窗口 DevTools', enabled: @window?, accelerator: 'Alt+CmdOrCtrl+Shift+I', click: => @window.toggleDevTools() }
            { label: '切换预览页 DevTools', enabled: @window?, accelerator: 'Alt+CmdOrCtrl+I', click: => @window.mdsWindow.send 'openDevTool' }
          ]
        }
      ]

      options:
        replacements:
          fileHistory: do =>
            historyMenu = MdsFileHistory.generateMenuItemTemplate(MdsWindow)
            historyMenu.push { type: 'separator' } if historyMenu.length > 0
            historyMenu.push
              label: '清除最近文件'
              enabled: historyMenu.length > 0
              click: =>
                MdsFileHistory.clear()
                MdsMainMenu.updateMenuToAll()
                @applyMenu()

            return historyMenu

    @applyMenu()
