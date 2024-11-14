# WickedPdf.config = {
#   exe_path: '/app/bin/wkhtmltopdf',
#   enable_local_file_access: true
# }

if Rails.env == "production"
  WickedPdf.config = {
    exe_path: '/app/bin/wkhtmltopdf',
    enable_local_file_access: true,
    default_font_family: "IPAexGothic"
  }
else
  WickedPdf.config = {
    exe_path: '/Users/yamashitamasahiro/.rbenv/shims/wkhtmltopdf',
    enable_local_file_access: true,
    default_font_family: "IPAexGothic"
  }
end
