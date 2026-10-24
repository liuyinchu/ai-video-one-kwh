require 'json'
require 'find'
require 'digest'

root = File.expand_path(ARGV.fetch(0))
entries = []
Find.find(root) do |path|
  next if path == root
  relative = path.delete_prefix(root + '/')
  stat = File.lstat(path)
  entry = { 'path' => relative, 'mode' => (stat.mode & 0o7777) }
  if stat.symlink?
    entry.merge!('type' => 'symlink', 'target' => File.readlink(path))
  elsif stat.directory?
    entry['type'] = 'directory'
  elsif stat.file?
    entry.merge!('type' => 'file', 'bytes' => stat.size, 'sha256' => Digest::SHA256.file(path).hexdigest)
  else
    abort "Unsupported file type: #{relative}"
  end
  entries << entry
end
entries.sort_by! { |entry| entry.fetch('path').b }
puts JSON.pretty_generate({ 'format' => 1, 'entries' => entries })
