variable lowerlevel_storage_account_name {}
variable lowerlevel_container_name {}
variable lowerlevel_key {}
variable lowerlevel_resource_group_name {}

variable tfstate_storage_account_name {}
variable tfstate_container_name {}
variable tfstate_key {}
variable tfstate_resource_group_name {}

variable landingzone_name {
  default = "aksapp"
}

variable namespaces {

}

variable remote_tfstate {

}

variable tags {
  default = null
  type    = map
}

variable helm_charts {

}

variable cluster_key {

}

variable level {
  default = "level4"
}

variable environment {
  default = "sandpit"
}

variable rover_version {
  default = null
}

