libvirt = {
  pool      = "openshift-metal3"
  pool_path = "/var/lib/libvirt/images/openshift-metal3"
}

dns = {
  domain = "ocp.metal3.lab"
  server = "10.10.0.1"
}

network_baremetal = {
  name    = "ocp-metal3-baremetal"
  subnet  = "10.10.0.0/24"
  gateway = "10.10.0.1"
  bridge  = "virbr-ocp-bm"
}

network_provisioning = {
  name       = "ocp-metal3-provisioning"
  subnet     = "10.20.0.0/24"
  gateway    = "10.20.0.1"
  bridge     = "virbr-ocp-prov"
  dhcp_range = "10.20.0.10,10.20.0.100"
}

ocp_registry_network = {
  ip  = "10.10.0.250"
  mac = "0A:00:00:00:00:00"
}

ocp_cluster = {
  name        = "ocp"
  dns_domain  = "metal3.lab"
  pods_cidr   = "172.0.0.0/16"
  pods_range  = 24
  svcs_cidr   = "172.255.0.0/16"
  num_masters = 3
  num_workers = 3
  bmc         = "redfish"
  api_vip     = "10.10.0.200"
  ingress_vip = "10.10.0.201"
}

ocp_inventory = {

  "master00" = {
    "network_baremetal" = {
      ip  = "10.10.0.11"
      mac = "AA:00:00:00:00:11"
    }
    "network_provisioning" = {
      mac = "BA:00:00:00:00:11"
    }
  }

  "master01" = {
    "network_baremetal" = {
      ip  = "10.10.0.12"
      mac = "AA:00:00:00:00:12"
    }
    "network_provisioning" = {
      mac = "BA:00:00:00:00:12"
    }
  }

  "master02" = {
    "network_baremetal" = {
      ip  = "10.10.0.13"
      mac = "AA:00:00:00:00:13"
    }
    "network_provisioning" = {
      mac = "BA:00:00:00:00:13"
    }
  }

  "worker00" = {
    "network_baremetal" = {
      ip  = "10.10.0.101"
      mac = "AA:00:00:00:01:01"
    }
    "network_provisioning" = {
      mac = "BA:00:00:00:01:01"
    }
  }

  "worker01" = {
    "network_baremetal" = {
      ip  = "10.10.0.102"
      mac = "AA:00:00:00:01:02"
    }
    "network_provisioning" = {
      mac = "BA:00:00:00:01:02"
    }
  }

  "worker02" = {
    "network_baremetal" = {
      ip  = "10.10.0.103"
      mac = "AA:00:00:00:01:03"
    }
    "network_provisioning" = {
      mac = "BA:00:00:00:01:03"
    }
  }

}
