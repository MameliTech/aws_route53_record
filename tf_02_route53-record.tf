#==================================================================
# route53-record.tf
#==================================================================

#------------------------------------------------------------------
# Data Source - Domain
#------------------------------------------------------------------
data "aws_route53_zone" "this" {
  name = var.domain_name
}


#------------------------------------------------------------------
# Route 53 DNS Record - General
#------------------------------------------------------------------
resource "aws_route53_record" "this" {
  zone_id                          = data.aws_route53_zone.this.zone_id
  name                             = var.name
  type                             = var.type
  ttl                              = var.alias-name != null ? null : var.ttl
  records                          = var.alias-name != null ? null : var.records
  set_identifier                   = var.set_identifier
  health_check_id                  = var.policy == "simple" ? null : var.health_check_id
  multivalue_answer_routing_policy = var.policy == "multivalue" ? true : null

  dynamic "alias" {
    for_each = var.alias-name != null ? [1] : []
    content {
      name                   = var.alias-name
      zone_id                = var.alias-zone_id
      evaluate_target_health = var.alias-evaluate_target_health
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = var.policy == "weighted" ? [1] : []
    content {
      weight = var.weighted-weight
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = var.policy == "geolocation" ? [1] : []
    content {
      continent   = var.geolocation-continent
      country     = var.geolocation-country
      subdivision = var.geolocation-subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = var.policy == "latency" ? [1] : []
    content {
      region = var.latency-region
    }
  }

  dynamic "failover_routing_policy" {
    for_each = var.policy == "failover" ? [1] : []
    content {
      type = var.failover-type
    }
  }

  dynamic "cidr_routing_policy" {
    for_each = var.policy == "ip-based" ? [1] : []
    content {
      collection_id = var.ip_based-collection_id
      location_name = var.ip_based-location_name
    }
  }

  lifecycle {
    ignore_changes = [
      multivalue_answer_routing_policy,
      zone_id
    ]
  }
}
