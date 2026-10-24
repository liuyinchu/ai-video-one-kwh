# encoding: UTF-8
require 'webrick'
root = File.expand_path('../output', __dir__)
server = WEBrick::HTTPServer.new(
  Port: Integer(ENV.fetch('VIDEO_PORT', '18326')),
  BindAddress: '127.0.0.1',
  DocumentRoot: root,
  MimeTypes: WEBrick::HTTPUtils::DefaultMimeTypes.merge('mp4' => 'video/mp4', 'srt' => 'text/plain; charset=utf-8', 'md' => 'text/plain; charset=utf-8', 'json' => 'application/json')
)
# Serve byte ranges in memory for browser media loaders; the film is ~29 MB.
server.mount_proc('/one-kwh.mp4') do |request, response|
  file = File.join(root, 'one-kwh.mp4')
  size = File.size(file)
  response['Content-Type'] = 'video/mp4'
  response['Accept-Ranges'] = 'bytes'
  response['Cache-Control'] = 'no-store'
  first, last = 0, size - 1
  if request['range'] && (m = /bytes=(\d+)-(\d*)/.match(request['range']))
    first = m[1].to_i
    last = [m[2].empty? ? size - 1 : m[2].to_i, size - 1].min
    response.status = 206
    response['Content-Range'] = "bytes #{first}-#{last}/#{size}"
  end
  if first > last || first >= size
    response.status = 416
    response['Content-Range'] = "bytes */#{size}"
    response.body = ''
  else
    response.body = File.binread(file, last - first + 1, first)
    response['Content-Length'] = response.body.bytesize.to_s
  end
end
trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }
server.start
