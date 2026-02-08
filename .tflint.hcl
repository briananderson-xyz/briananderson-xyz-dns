config {
  module = true
  force   = false
  
  plugin_dir = "~/.tflint.d/plugins"

  rules {
    terraform_deprecated_interpolation = true
    terraform_deprecated_index       = true
    terraform_unused_declarations   = true
    terraform_comment_syntax        = true
  }
}
