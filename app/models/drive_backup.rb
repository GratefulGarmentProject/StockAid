# frozen_string_literal: true
require "google/apis/drive_v3"
require "googleauth"

class DriveBackup
  FOLDER_MIME_TYPE = "application/vnd.google-apps.folder".freeze

  def backup
    Rails.logger.info "Backing up to Drive"
    return Rails.logger.error "Cannot backup to Drive as requested due to missing config!" unless available?

    Backup.new do |backup|
      return Rails.logger.error "Cannot backup to Drive as requested due to failed backup!" if backup.error?
      save_backup(backup.filename, backup.tempfile_path)
    end

    delete_backups_if_needed
  end

  def available?
    google_config.service_account_json.present?
  end

  private

  def authorization
    @authorization ||= Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(google_config.service_account_json),
      scope: "https://www.googleapis.com/auth/drive")
  end

  def drive_service
    @drive_service ||=
      begin
        Google::Apis::DriveV3::DriveService.new.tap do |service|
          service.authorization = authorization
        end
      end
  end

  def folder
    @folder ||=
      begin
        folder = drive_service.list_files(fields: "files/id",
                                          q: "name = '#{google_config.folder}' and 'root' in parents")

        if folder.files.empty?
          create_folder
        else
          folder.files.first
        end
      end
  end

  def create_folder
    Rails.logger.warn "Could not find Drive folder #{google_config.folder.inspect}, creating now"
    drive_service.create_file({ name: google_config.folder, mime_type: FOLDER_MIME_TYPE }, fields: "id")
  end

  def save_backup(filename, path)
    file = drive_service.create_file({ name: filename, parents: [folder.id] },
                                     fields: "id,name",
                                     upload_source: path,
                                     content_type: "application/octet-stream")
    Rails.logger.info "Backed up database to Drive file #{file.id.inspect}, #{file.name.inspect}"
  end

  def delete_backups_if_needed
    return Rails.logger.info "Preserving Drive backups (config: #{backup_count})" if backup_count < 1
    Rails.logger.info "Checking for old Drive backups to delete"
    results = drive_service.list_files(fields: "files(id,modifiedTime,name)",
                                       q: "name contains '#{Backup::PREFIX}' and '#{folder.id}' in parents")
    delete_old_backups(results.files)
  end

  def delete_old_backups(original_files)
    files = original_files.select { |x| Backup.file?(x.name) }.sort_by(&:modified_time).reverse.drop(backup_count)
    Rails.logger.info "Deleting #{files.size} old Drive backups, total: #{original_files.size}, config: #{backup_count}"
    files.each { |file| delete_backup(file) }
  end

  def delete_backup(file)
    Rails.logger.warn "Deleting old Drive backup #{file.id.inspect}, #{file.name.inspect}"
    drive_service.delete_file(file.id)
  end

  def google_config
    Rails.application.config.google_drive
  end

  def backup_count
    google_config.backup_count
  end
end
