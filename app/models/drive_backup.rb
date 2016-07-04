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
  end

  def available?
    config.service_account_json.present?
  end

  private

  def authorization
    @authorization ||= Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(config.service_account_json),
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
        folder = drive_service.list_files(fields: "files/id", q: "name = '#{config.folder}' and 'root' in parents")

        if folder.files.empty?
          create_folder
        else
          folder.files.first
        end
      end
  end

  def create_folder
    Rails.logger.warn "Could not find Drive folder #{config.folder.inspect}, creating now"
    drive_service.create_file({ name: config.folder, mime_type: FOLDER_MIME_TYPE }, fields: "id")
  end

  def save_backup(filename, path)
    file = drive_service.create_file({ name: filename, parents: [folder.id] },
                                     fields: "id",
                                     upload_source: path,
                                     content_type: "application/octet-stream")
    Rails.logger.info "Backed up database to Drive file #{file.id.inspect}"
  end

  def config
    Rails.application.config.google_drive
  end
end
