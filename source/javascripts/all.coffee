# = require_tree .
# = require jquery
# = require jquery-serialize-object
# = require underscore
# = require underscore.string/dist/underscore.string.min
# = require messenger/build/js/messenger
# = require messenger/build/js/messenger-theme-future
# = require ace-builds/src-noconflict/ace.js
if @require?
  @request = @require 'request'
  @moment = @require 'moment'
  @moment.lang 'zh-cn'
  @async = @require 'async'
  @fs = @require 'fs'
  @os = @require 'os'
  @path = @require 'path'
  @mkdirp = @require 'mkdirp'
  @gui = @require 'nw.gui'
try
  @m_favs = JSON.parse(localStorage.favs)||{}
catch
  @m_favs = {}
@refresh_favs = =>
  $ '#favs'
    .empty()
  for k, fav of @m_favs
    $ li = document.createElement 'li'
      .appendTo '#favs'
    $ document.createElement 'a'
      .appendTo li
      .text k
      .attr href: '#'
      .data 'fav', fav
      .click (ev)=>
        ev.preventDefault()
        $(ev.currentTarget).parent().addClass('active').siblings().removeClass 'active'
        for k, v of $(ev.currentTarget).data 'fav'
          $ "#input#{_.str.capitalize k}"
            .val v
        $ '#formLogin'
          .submit()
    $ document.createElement 'button'
      .appendTo li
      .prepend @createIcon 'trash-o'
      .addClass 'btn btn-danger btn-xs'
      .data 'fav', fav
      .click (ev)=>
        fav = $(ev.currentTarget).data 'fav'
        delete @m_favs["#{fav.username}@#{fav.bucket}"]
        localStorage.favs = JSON.stringify @m_favs
        @refresh_favs()
@humanFileSize = (bytes, si) ->
  thresh = (if si then 1000 else 1024)
  return bytes + " B"  if bytes < thresh
  units = (if si then [
    "kB"
    "MB"
    "GB"
    "TB"
    "PB"
    "EB"
    "ZB"
    "YB"
  ] else [
    "KiB"
    "MiB"
    "GiB"
    "TiB"
    "PiB"
    "EiB"
    "ZiB"
    "YiB"
  ])
  u = -1
  loop
    bytes /= thresh
    ++u
    break unless bytes >= thresh
  bytes.toFixed(1) + " " + units[u]
@upyun_messages = 
  '200 OK': '操作成功'
  '404': '找不到文件'
  '400 Bad Request': '错误请求(如 URL 缺少空间名)'
  '401 Unauthorized': '访问未授权'
  '401 Sign error': '签名错误(操作员和密码,或签名格式错误)'
  '401 Need Date Header': '发起的请求缺少 Date 头信息'
  '401 Date offset error': '发起请求的服务器时间错误，请检查服务器时间是否与世界时间一致'
  '403 Not Access': '权限错误(如非图片文件上传到图片空间)'
  '403 File size too max': '单个文件超出大小(100Mb 以内)'
  '403 Not a Picture File': '图片类空间错误码，非图片文件或图片文件格式错误。针对图片空间只允许上传 jpg/png/gif/bmp/tif 格式。'
  '403 Picture Size too max': '图片类空间错误码，图片尺寸太大。针对图片空间，图片总像素在 200000000 以内。'
  '403 Bucket full': '空间已用满'
  '403 Bucket blocked': '空间被禁用,请联系管理员'
  '403 User blocked': '操作员被禁用'
  '403 Image Rotate Invalid Parameters': '图片旋转参数错误'
  '403 Image Crop Invalid Parameters': '图片裁剪参数错误'
  '404 Not Found': '获取文件或目录不存在；上传文件或目录时上级目录不存在'
  '406 Not Acceptable(path)': '目录错误（创建目录时已存在同名文件；或上传文件时存在同名目录)'
  '503 System Error': '系统错误'
@_upyun_api = (opt, cb)=>
  opt.headers?= {}
  if opt.data?
    opt.headers["Content-Length"] = opt.data.length
  req = request
    method: opt.method
    url: "https://v0.api.upyun.com/#{@bucket}#{opt.url}"
    headers: opt.headers
    body: opt.data
    auth:
      user: @username
      pass: @password
      sendImmediately: true
    , (e, res, data)=>
      return cb e if e
      if res.statusCode == 200
        cb null, data
      else
        status = String res.statusCode
        if res.body
          statusMatch = res.body.match(/\<h\d\>\d+\s(.+)\<\/\s*h\d\>/)
          if status = statusMatch?[1]
            status = "#{res.statusCode} #{status}"
          else
            status = res.body
        status = @upyun_messages[status]||status
        cb new Error status
  req.pipe opt.pipe if opt.pipe
  req.on 'data', opt.onData if opt.onData 
  return =>
    req.abort()
    cb new Error '操作已取消'
@upyun_api = (opt, cb)=>
  start = Date.now()
  @_upyun_api opt, (e, data)=>
    console?.log "#{opt.method} #{opt.url} done (+#{Date.now() - start}ms)"
    cb e, data

Messenger.options = 
  extraClasses: 'messenger-fixed messenger-on-bottom messenger-on-right'
  theme: 'future'
  messageDefaults:
    showCloseButton: true
    hideAfter: 10
    retry:
      label: '重试'
      phrase: 'TIME秒钟后重试'
      auto: true
      delay: 5
@createIcon = (icon)=>
  $ document.createElement 'i'
    .addClass "fa fa-#{icon}"
@shortOperation = (title, operation)=>
  $ '#loadingText'
    .text title||''
  $ 'body'
    .addClass 'loading'
  $ btnCancel = document.createElement 'button'
    .appendTo '#loadingText'
    .addClass 'btn btn-default btn-xs btn-inline'
    .text '取消'
    .hide()
  operationDone = (e)=>
    $ 'body'
      .removeClass 'loading'
    if e
      msg = Messenger().post
        type: 'error'
        message: e.message
        showCloseButton: true
        actions: 
          ok:
            label: '确定'
            action: =>
              msg.hide()
          retry:
            label: '重试'
            action: =>
              msg.hide()
              @shortOperation title, operation
  operation operationDone, $ btnCancel
      
@taskOperation = (title, operation)=>
  msg = Messenger(
      instance: @messengerTasks
      extraClasses: 'messenger-fixed messenger-on-left messenger-on-bottom'
    ).post 
    hideAfter: 0
    message: title
    actions:
      cancel:
        label: '取消'
        action: =>
  $progresslabel1 = $ document.createElement 'span'
    .appendTo msg.$message.find('.messenger-message-inner')
    .addClass 'pull-right'
  $progressbar = $ document.createElement 'div'
    .appendTo msg.$message.find('.messenger-message-inner')
    .addClass 'progress progress-striped active'
    .css margin: 0
    .append $(document.createElement 'div').addClass('progress-bar').width '100%'
    .append $(document.createElement 'div').addClass('progress-bar progress-bar-success').width '0%'
  $progresslabel2 = $ document.createElement 'div'
    .appendTo msg.$message.find('.messenger-message-inner')
  operationProgress = (progress, progresstext)=>
    $progresslabel2.text progresstext if progresstext
    $progresslabel1.text "#{progress}%" if progress?
    $progressbar
      .toggleClass 'active', !progress?
    $progressbar.children ':not(.progress-bar-success)'
      .toggle !progress?
    $progressbar.children '.progress-bar-success'
      .toggle progress?
      .width "#{progress}%"
  operationDone = (e)=>
    return unless msg
    if e
      msg.update
        type: 'error'
        message: e.message
        showCloseButton: true
        actions: 
          ok:
            label: '确定'
            action: =>
              msg.hide()
          retry:
            label: '重试'
            action: =>
              msg.hide()
              @taskOperation title, operation
    else
      msg.hide()
  operationProgress null
  operation operationProgress, operationDone, msg.$message.find('[data-action="cancel"] a')

@upyun_readdir = (url, cb)=>
  @upyun_api 
    method: "GET"
    url: url
    , (e, data)=>
      return cb e if e
      files = data.split('\n').map (line)-> 
        line = line.split '\t'
        return null unless line.length == 4
        return (
          filename: line[0]
          url: url + encodeURIComponent line[0]
          isDirectory: line[1]=='F'
          length: Number line[2]
          mtime: 1000 * Number line[3]
        )
      cb null, files.filter (file)-> file?
@upyun_find_abort = ->
@upyun_find = (url, cb)=>
  results = []
  @upyun_find_abort = @upyun_readdir url, (e, files)=>
    return cb e if e
    @async.eachSeries files, (file, doneEach)=>
        if file.isDirectory
          @upyun_find file.url + '/', (e, tmp)=>
            return doneEach e if e
            results.push item for item in tmp
            results.push file
            doneEach null
        else
          results.push file
          _.defer => doneEach null
      , (e)=> 
        @upyun_find_abort = ->
        cb e, results
@uypun_upload = (url, files, onProgress, cb)=>
  aborted = false
  api_aborting = null
  aborting = =>
    aborted = true
    api_aborting() if api_aborting?
  status = 
    total_files: files.length
    total_bytes: files.reduce ((a, b)-> a + b.length), 0
    current_files: 0
    current_bytes: 0
  @async.eachSeries files, (file, doneEach)=>
      @fs.readFile file.path, (e, data)=>
        return doneEach e if e
        return doneEach (new Error '操作已取消') if aborted
        data = undefined unless data.length
        api_aborting = @upyun_api 
          method: "PUT"
          headers:
            'mkdir': 'true'
          url: url + file.url
          data: data
          , (e)=>
            status.current_files+= 1
            status.current_bytes+= file.length
            onProgress status
            doneEach e
    , cb
  return aborting

@nwsaveas = (filename, cb)=>
  $ dlg = document.createElement 'input'
    .appendTo 'body'
    .css position: 'absolute', top: - 50
    .attr type: 'file', nwsaveas: filename
    .on 'change', =>
      val = $(dlg).val()
      $(dlg).remove()
      cb val
    .trigger 'click'
@nwdirectory = (cb)=>
  $ dlg = document.createElement 'input'
    .appendTo 'body'
    .css position: 'absolute', top: - 50
    .attr type: 'file', nwdirectory: true
    .on 'change', =>
      val = $(dlg).val()
      $(dlg).remove()
      cb val
    .trigger 'click'
@jump_login = =>
  @m_path = '/'
  @m_active = false
  @refresh_favs()
  $ '#filelist, #editor'
    .hide()
  $ '#login'
    .fadeIn()

@jump_filelist = =>
  @jump_path '/'  
@jump_path = (path)=>
  @m_path = path
  @m_active = true
  @m_files = null
  $ document.createElement 'div'
    .addClass 'preloader'
    .appendTo '#filelist'
  $ '#inputFilter'
    .val ''
  $ '#login, #editor'
    .hide()
  $ '#filelist'
    .fadeIn()
  segs = $.makeArray(@m_path.match /\/[^\/]+/g).map (match)-> String(match).replace /^\//, ''
  segs = segs.map decodeURIComponent
  $ '#path'
    .empty()
  $ li = document.createElement 'li'
    .appendTo '#path'
  $ document.createElement 'a'
    .appendTo li
    .text @username
    .prepend @createIcon 'user'
    .attr 'href', '#'
    .click (ev)=>
      ev.preventDefault()
      @jump_login()
  $ li = document.createElement 'li'
    .toggleClass 'active', !segs.length
    .appendTo '#path'
  $ document.createElement 'a'
    .appendTo li
    .text @bucket
    .prepend @createIcon 'cloud'
    .attr 'href', "http://#{bucket}.b0.upaiyun.com/"
    .data 'url', '/'
  for seg, i in segs
    url = '/' + segs[0..i].map(encodeURIComponent).join('/') + '/'
    $ li = document.createElement 'li'
      .toggleClass 'active', i == segs.length - 1
      .appendTo '#path'
    $ document.createElement 'a'
      .appendTo li
      .text seg
      .prepend @createIcon 'folder'
      .attr 'href', "http://#{bucket}.b0.upaiyun.com#{url}"
      .data 'url', url
  $ '#path li:not(:first-child)>a'
    .click (ev)=>
      ev.preventDefault()
      @jump_path $(ev.currentTarget).data 'url'

@refresh_filelist = (cb)=>
  cur_path = @m_path
  @upyun_readdir cur_path, (e, files)=>
    return cb e if e
    if @m_path == cur_path && JSON.stringify(@m_files) != JSON.stringify(files)
      $('#filelist tbody').empty()
      $('#filelist .preloader').remove()
      for file in @m_files = files
        $ tr = document.createElement 'tr'
          .appendTo '#filelist tbody'
        $ td = document.createElement 'td'
          .appendTo tr
        if file.isDirectory
          $ a = document.createElement 'a'
            .appendTo td
            .text file.filename
            .prepend @createIcon 'folder'
            .attr 'href', "#"
            .data 'url', file.url + '/'
            .click (ev)=> 
              ev.preventDefault()
              @jump_path $(ev.currentTarget).data('url')
        else
          $ td
            .text file.filename
            .prepend @createIcon 'file'
        $ document.createElement 'td'
          .appendTo tr
          .text if file.isDirectory then '' else @humanFileSize file.length
        $ document.createElement 'td'
          .appendTo tr
          .text @moment(file.mtime).format 'LLL'
        $ td = document.createElement 'td'
          .appendTo tr
        if file.isDirectory
          $ document.createElement 'button'
            .appendTo td
            .addClass 'btn btn-danger btn-xs'
            .data 'url', file.url + '/'
            .data 'filename', file.filename
            .prepend @createIcon 'trash-o'
            .click (ev)=>
              filename = $(ev.currentTarget).data 'filename'
              url = $(ev.currentTarget).data 'url'
              @shortOperation "正在列出目录 #{filename} 下的所有文件", (doneFind, $btnCancelFind)=>
                $btnCancelFind.show().click => @upyun_find_abort()
                @upyun_find url, (e, files)=>
                  doneFind e
                  unless e
                    files_deleting = 0
                    async.eachSeries files, (file, doneEach)=>
                        files_deleting+= 1
                        @shortOperation "正在删除(#{files_deleting}/#{files.length}) #{file.filename}", (operationDone, $btnCancelDel)=>
                          $btnCancelDel.show().click @upyun_api 
                            method: "DELETE"
                            url: file.url
                            , (e)=>
                              operationDone e
                              doneEach e
                      , (e)=>
                        unless e
                          @shortOperation "正在删除 #{filename}", (operationDone, $btnCancelDel)=>
                            $btnCancelDel.show().click @upyun_api 
                              method: "DELETE"
                              url: url
                              , operationDone
        else
          $ document.createElement 'button'
            .appendTo td
            .addClass 'btn btn-danger btn-xs'
            .data 'url', file.url
            .data 'filename', file.filename
            .prepend @createIcon 'trash-o'
            .click (ev)=>
              url = $(ev.currentTarget).data('url')
              filename = $(ev.currentTarget).data('filename')
              @shortOperation "正在删除 #{filename}", (operationDone, $btnCancelDel)=>
                $btnCancelDel.show().click @upyun_api 
                  method: "DELETE"
                  url: url
                  , operationDone
        if file.isDirectory
          $ document.createElement 'button'
            .appendTo td
            .addClass 'btn btn-info btn-xs'
            .prepend @createIcon 'download'
            .data 'url', file.url + '/'
            .data 'filename', file.filename
            .click (ev)=>
              filename = $(ev.currentTarget).data 'filename'
              url = $(ev.currentTarget).data 'url'
              @shortOperation "正在列出目录 #{filename} 下的所有文件", (doneFind, $btnCancelFind)=>
                $btnCancelFind.show().click => @upyun_find_abort()
                @upyun_find url, (e, files)=>
                  doneFind e
                  unless e
                    @nwdirectory (savepath)=>
                      @taskOperation "正在下载目录 #{filename} ...", (progressTransfer, doneTransfer, $btnCancelTransfer)=>
                        total_files = files.length
                        total_bytes = files.reduce ((a, b)-> a + b.length), 0
                        current_files = 0
                        current_bytes = 0
                        aborting = null
                        $btnCancelTransfer.click =>
                          aborting() if aborting?
                        @async.eachSeries files, ((file, doneEach)=>
                          return (_.defer => doneEach null) if file.isDirectory()
                          segs = file.url.substring(url.length).split '/'
                          segs = segs.map decodeURIComponent
                          destpath = @path.join savepath, @path.join.apply @path, segs
                          @mkdirp @path.dirname(destpath), (e)=>
                            return doneEach e if e
                            stream = @fs.createWriteStream destpath
                            stream.on 'error', doneEach
                            stream.on 'open', =>
                              current_files+= 1
                              aborting = @upyun_api 
                                method: 'GET'
                                url: file.url
                                pipe: stream
                                onData: =>
                                  progressTransfer (Math.floor 100 * (current_bytes + stream.bytesWritten) / total_bytes), "已下载：#{current_files} / #{total_files} (#{@humanFileSize current_bytes + stream.bytesWritten} / #{@humanFileSize total_bytes})"
                                , (e)=>
                                  current_bytes+= file.length unless e
                                  doneEach e

                          ), (e)=> 
                            aborting = null
                            doneTransfer e
                            unless e
                              msg = Messenger().post
                                message: "目录 #{filename} 下载完毕"
                                actions: 
                                  ok:
                                    label: '确定'
                                    action: =>
                                      msg.hide()
                                  open: 
                                    label: "打开"
                                    action: => 
                                      msg.hide()
                                      @gui.Shell.openItem savepath
        else
          $ document.createElement 'button'
            .appendTo td
            .addClass 'btn btn-info btn-xs'
            .prepend @createIcon 'download'
            .data 'url', file.url
            .data 'filename', file.filename
            .data 'length', file.length
            .click (ev)=>
              filename = $(ev.currentTarget).data 'filename'
              url = $(ev.currentTarget).data 'url'
              length = $(ev.currentTarget).data 'length'
              @nwsaveas filename, (savepath)=>
                @taskOperation "正在下载文件 #{filename} ..", (progressTransfer, doneTransfer, $btnCancelTransfer)=>
                  aborting = null
                  $btnCancelTransfer.click =>
                    aborting() if aborting?
                  stream = @fs.createWriteStream savepath
                  stream.on 'error', doneTransfer
                  stream.on 'open', =>
                    aborting = @upyun_api 
                      method: "GET"
                      url: url
                      pipe: stream
                      onData: =>
                        progressTransfer (Math.floor 100 * stream.bytesWritten / length), "#{@humanFileSize stream.bytesWritten} / #{@humanFileSize length}"
                      , (e, data)=>
                        doneTransfer e
                        unless e
                          msg = Messenger().post
                            message: "文件 #{filename} 下载完毕"
                            actions: 
                              ok:
                                label: '确定'
                                action: =>
                                  msg.hide()
                              open: 
                                label: "打开"
                                action: => 
                                  msg.hide()
                                  @gui.Shell.openItem savepath
                              showItemInFolder: 
                                label: "打开目录"
                                action: => 
                                  msg.hide()
                                  @gui.Shell.showItemInFolder savepath
          $ document.createElement 'button'
            .appendTo td
            .addClass 'btn btn-info btn-xs'
            .prepend @createIcon 'globe'
            .data 'url', "http://#{@bucket}.b0.upaiyun.com#{file.url}"
            .click (ev)=>
              url = $(ev.currentTarget).data 'url'
              @gui.Shell.openExternal url
          $ document.createElement 'button'
            .appendTo td
            .addClass 'btn btn-info btn-xs'
            .prepend @createIcon 'edit'
            .data 'url', file.url
            .data 'filename', file.filename
            .click (ev)=>
              @open '?' + $.param
                username: @username
                password: @password
                bucket: @bucket
                default_action: 'editor'
                editor_url: $(ev.currentTarget).data 'url'
                editor_filename: $(ev.currentTarget).data 'filename'
    cb null
@jump_editor = =>
  $ '#login, #filelist'
    .hide()
  $ '#editor'
    .show()
  @editor = @ace.edit $('#editor .editor')[0]
  $('#btnReloadEditor').click()


window.ondragover = window.ondrop = (ev)-> 
  ev.preventDefault()
  return false
$ =>
  $ document.createElement 'div'
    .appendTo 'body'
    .attr 'id', 'loading'
  $ document.createElement 'div'
    .appendTo 'body'
    .attr 'id', 'loadingText'
  for i in [1..5]
    $ document.createElement 'div'
      .addClass 'dot'
      .appendTo '#loading'
  @messengerTasks = $ document.createElement 'ul'
    .appendTo 'body'
    .messenger()
  @async.forever (doneForever)=>
      setTimeout =>
          if @m_active
            @refresh_filelist (e)=>
              if e
                msg = Messenger().post
                  message: e.message
                  type: 'error'
                  actions: 
                    ok:
                      label: '确定'
                      action: =>
                        msg.hide()
                @jump_login()
              doneForever null
          else
            doneForever null
        , 100
    , (e)=>
      throw e



  $ '#btnAddFav'
    .click =>
      fav = $('#formLogin').serializeObject()
      @m_favs["#{fav.username}@#{fav.bucket}"] = fav
      localStorage.favs = JSON.stringify @m_favs
      @refresh_favs()
  $ '#formLogin'
    .submit (ev)=>
      ev.preventDefault()
      @[k] = v for k, v of $(ev.currentTarget).serializeObject()
      $ '#filelist tbody'
        .empty()
      @jump_filelist()
  $ window
    .on 'dragover', -> $('body').addClass 'drag_hover'
    .on 'dragleave', -> $('body').removeClass 'drag_hover'
    .on 'dragend', -> $('body').removeClass 'drag_hover'
    .on 'drop', (ev)=> 
      $('body').removeClass 'drag_hover'
      ev.preventDefault()
      for transferFile in ev.originalEvent.dataTransfer.files
        name = transferFile.name
        @taskOperation "正在上传 #{transferFile.name}", (progressTransfer, doneTransfer, $btnCancelTransfer)=>
          files = []
          loadfileSync = (file)=>
            stat = @fs.statSync(file.path)
            if stat.isFile()
              file.length = stat.size
              files.push file 
            if stat.isDirectory()
              for filename in @fs.readdirSync file.path
                loadfileSync 
                  path: @path.join(file.path, filename)
                  url: file.url + '/' + encodeURIComponent filename
          try
            loadfileSync path: transferFile.path, url: encodeURIComponent transferFile.name
          catch e
            return doneTransfer e if e
          $btnCancelTransfer.show().click @uypun_upload @m_path, files, (status)=>
              progressTransfer (Math.floor 100 * status.current_bytes / status.total_bytes), "已上传：#{status.current_files} / #{status.total_files} (#{@humanFileSize status.current_bytes} / #{@humanFileSize status.total_bytes})"
            , (e)=>
              doneTransfer e
              unless e
                msg = Messenger().post
                  message: "文件 #{name} 上传完毕"
                  actions: 
                    ok:
                      label: '确定'
                      action: =>
                        msg.hide()
  $ '#inputFilter'
    .keydown =>
      _.defer =>
        val = String $('#inputFilter').val()
        $ "#filelist tbody tr:contains(#{JSON.stringify val})"
          .removeClass 'filtered'
        $ "#filelist tbody tr:not(:contains(#{JSON.stringify val}))"
          .addClass 'filtered'
  $ '#btnReloadEditor'
    .click (ev)=>
      ev.preventDefault()
      @shortOperation "正在加载文件 #{editor_filename} ...", (doneReloading, $btnCancelReloading)=>
        $btnCancelReloading.click @upyun_api 
          url: @editor_url
          method: 'GET'
          , (e, data)=>
            if e
              data = '' 
            else
              data = data.toString 'utf8'
            doneReloading null
            unless e
              @editor.setValue data
  $ '#btnSaveEditor'
    .click (ev)=>
      ev.preventDefault()
      @shortOperation "正在保存文件 #{editor_filename} ...", (doneSaving, $btnCancelSaving)=>
        $btnCancelSaving.click @upyun_api 
            url: @editor_url
            method: 'PUT'
            data: new Buffer @editor.getValue(), 'utf8'
          , doneSaving
  for m in location.search.match(/([^\&?]+)\=([^\&]+)/g)||[]
    m = m.split '='
    @[decodeURIComponent m[0]] = decodeURIComponent m[1]
  (@["jump_#{@default_action}"]||@jump_login)()
        

