require 'json'
require 'digest'

checkout = File.expand_path(ARGV.fetch(0))
original_git = File.expand_path(ARGV.fetch(1))
manifest = JSON.parse(File.read(File.join(checkout, 'BACKUP/original-manifest.json')))
errors = []
counts = Hash.new(0)
bytes = 0
manifest.fetch('entries').each do |entry|
  relative = entry.fetch('path')
  base = (relative == '.git' || relative.start_with?('.git/')) ? original_git : checkout
  path = File.join(base, relative)
  begin
    stat = File.lstat(path)
    errors << "Mode differs: #{relative}" unless (stat.mode & 0o7777) == entry.fetch('mode')
    case entry.fetch('type')
    when 'file'
      errors << "Type differs: #{relative}" unless stat.file?
      errors << "Size differs: #{relative}" unless stat.size == entry.fetch('bytes')
      errors << "SHA256 differs: #{relative}" unless Digest::SHA256.file(path).hexdigest == entry.fetch('sha256')
      bytes += entry.fetch('bytes')
    when 'directory'
      errors << "Type differs: #{relative}" unless stat.directory?
    when 'symlink'
      errors << "Symlink differs: #{relative}" unless stat.symlink? && File.readlink(path) == entry.fetch('target')
    end
    counts[entry.fetch('type')] += 1
  rescue => error
    errors << "#{relative}: #{error.class}"
  end
end
puts JSON.pretty_generate({passed: errors.empty?, counts: counts, file_bytes: bytes, errors: errors})
exit(errors.empty? ? 0 : 1)
