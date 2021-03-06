locals {

  ocp_pull_secret_redhat = file(
    format("%s/openshift-install/%s/pull-secret.json", path.module, var.OCP_ENVIRONMENT)
  )

  ocp_pull_secret = jsonencode({
    auths = merge(jsondecode(local.ocp_pull_secret_redhat).auths, local.ocp_registry_auth.auths)
  })

}

resource "local_file" "ocp_pull_secret" {
  filename             = format("output/openshift-install/%s/pull-secret.json", var.OCP_ENVIRONMENT)
  content              = local.ocp_pull_secret
  file_permission      = "0640"
  directory_permission = "0750"
}
