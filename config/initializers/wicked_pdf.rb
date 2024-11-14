# WickedPdf.config = {
#   exe_path: '/app/bin/wkhtmltopdf',
#   enable_local_file_access: true
# }

if Rails.env == "production"
  WickedPdf.config = {
    exe_path: '/app/bin/wkhtmltopdf',
    enable_local_file_access: true
  }
else
  WickedPdf.config = {
    exe_path: '/Users/yamashitamasahiro/.rbenv/shims/wkhtmltopdf',
    enable_local_file_access: true
  }
end
