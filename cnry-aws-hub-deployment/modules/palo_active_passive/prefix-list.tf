#----------------------------------------------------------------------------------------------------------------------
# Prefix Lists - HA Interfaces for Management SG
#----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_managed_prefix_list" "ha-interfaces" {
  name                                      = "Firewall-Interfaces-PL"
  address_family                            = "IPv4"
  max_entries                               = 6

  entry {
    cidr                                    = join("", [cidrhost(var.hub_address_space[0], 36), "/32"])
  }

  entry {
    cidr                                    = join("", [cidrhost(var.hub_address_space[0], 37), "/32"])
  }

  entry {A
    cidr                                    = join("", [cidrhost(var.hub_address_space[0], 4), "/32"])
  }

  entry {
    cidr                                    = join("", [cidrhost(var.hub_address_space[0], 5), "/32"])
  }

}

#----------------------------------------------------------------------------------------------------------------------
# Prefix Lists - Internet Access - Management IF SG
#----------------------------------------------------------------------------------------------------------------------

resource "aws_ec2_managed_prefix_list" "internet-pl" {
  name                                      = "Internet-Access-PL"
  address_family                            = "IPv4"
  max_entries                               = 30

  entry {
    cidr                                    = "0.0.0.0/5"
  }

  entry {
    cidr                                    = "8.0.0.0/7"
  }

  entry {
    cidr                                    = "11.0.0.0/8"
  }

  entry {
    cidr                                    = "12.0.0.0/6"
  }

  entry {
    cidr                                    = "16.0.0.0/4"
  }

  entry {
    cidr                                    = "32.0.0.0/3"
  }

  entry {
    cidr                                    = "64.0.0.0/2"
  }

  entry {
    cidr                                    = "128.0.0.0/3"
  }

  entry {
    cidr                                    = "160.0.0.0/5"
  }

  entry {
    cidr                                    = "168.0.0.0/6"
  }

  entry {
    cidr                                    = "172.0.0.0/12"
  }

  entry {
    cidr                                    = "172.32.0.0/11"
  }

  entry {
    cidr                                    = "172.64.0.0/10"
  }

  entry {
    cidr                                    = "172.128.0.0/9"
  }

  entry {
    cidr                                    = "173.0.0.0/8"
  }

  entry {
    cidr                                    = "174.0.0.0/7"
  }

  entry {
    cidr                                    = "176.0.0.0/4"
  }

  entry {
    cidr                                    = "192.0.0.0/9"
  }

  entry {
    cidr                                    = "192.128.0.0/11"
  }

  entry {
    cidr                                    = "192.160.0.0/13"
  }

  entry {
    cidr                                    = "192.169.0.0/16"
  }

  entry {
    cidr                                    = "192.170.0.0/15"
  }

  entry {
    cidr                                    = "192.172.0.0/14"
  }

  entry {
    cidr                                    = "192.176.0.0/12"
  }

  entry {
    cidr                                    = "192.192.0.0/10"
  }

  entry {
    cidr                                    = "193.0.0.0/8"
  }

  entry {
    cidr                                    = "194.0.0.0/7"
  }

  entry {
    cidr                                    = "196.0.0.0/6"
  }

  entry {
    cidr                                    = "200.0.0.0/5"
  }

  entry {
    cidr                                    = "208.0.0.0/4"
  }
}