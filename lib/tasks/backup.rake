desc "Backup StockAid to Google Drive (if configured)"
task backup: [:environment, :stdout_logger] do
  drive_backup = DriveBackup.new
  abort "Google Drive is not configured!" unless drive_backup.available?
  drive_backup.backup
end
