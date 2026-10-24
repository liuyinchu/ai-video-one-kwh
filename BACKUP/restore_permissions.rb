require 'json'
require 'fileutils'

root = File.expand_path('..', __dir__)
manifest = JSON.parse(File.read(File.join(__dir__, 'original-manifest.json')))
changed = []
manifest.fetch('entries').each do |entry|
  relative = entry.fetch('path')
  next if relative == '.git' || relative.start_with?('.git/')
  abort "Unsafe manifest path: #{relative}" if relative.start_with?('/') || relative.split('/').include?('..')
  path = File.join(root, relative)
  if entry.fetch('type') == 'directory'
    FileUtils.mkdir_p(path)
  elsif entry.fetch('type') == 'symlink'
    next
  end
  unless (File.lstat(path).mode & 0o7777) == entry.fetch('mode')
    File.chmod(entry.fetch('mode'), path)
    changed << relative
  end
end
puts JSON.pretty_generate({restored: changed})
