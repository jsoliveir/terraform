
locals {
  config = yamldecode(file("${path.module}/@template.yml"))
}
