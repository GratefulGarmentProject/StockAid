desc "Backup StockAid to Google Drive (if configured)"
task backup: :environment do
  drive_backup = DriveBackup.new
  abort "Google Drive is not configured!" unless drive_backup.available?
  drive_backup.backup
end
