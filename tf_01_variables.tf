#==================================================================
# route53-record - variables.tf
#==================================================================

#------------------------------------------------------------------
# Route 53 DNS Record - General
#------------------------------------------------------------------
variable "domain_name" {
  description = "Dominio existente no Route 53 Hosted Zone."
  type        = string
}

variable "name" {
  description = "Subdominio do registro."
  type        = string
}

variable "type" {
  description = "Tipo de registro."
  type        = string
}

variable "ttl" {
  description = "Time-to-Live (TTL) do registro."
  type        = number
}

variable "records" {
  description = "Lista de destinos associados ao subdominio."
  type        = list(string)
  default     = []
}

variable "set_identifier" {
  description = "ID que deseja associar ao registro."
  type        = string
  default     = null
}

variable "health_check_id" {
  description = "ID do Health Check do Route 53 associada ao registro."
  type        = string
  default     = null
}


#------------------------------------------------------------------
# Route 53 DNS Record - Alias
#------------------------------------------------------------------
variable "alias-name" {
  description = "Nome do recurso destino."
  type        = string
  default     = null
}

variable "alias-zone_id" {
  description = "Zone ID do recurso destino."
  type        = string
  default     = null
}

variable "alias-evaluate_target_health" {
  description = "Determina se o Route 53 deve avaliar a saude dos destinos associados ao alias."
  type        = bool
  default     = true
}


#------------------------------------------------------------------
# Route 53 DNS Record - Routing Policies
#------------------------------------------------------------------
variable "policy" {
  description = "Identifica qual politica deve ser adotada para o registro. Valores possiveis: simple, weighted, geolocation, failover, latency, ip-based ou multivalue."
  type        = string
  default     = null
}


# Weighted
#---------
variable "weighted-weight" {
  description = "Valor numerico que indica o peso relativo do registro."
  type        = number
  default     = null
}


# Geolocation
#------------
variable "geolocation-continent" {
  description = "Codigo de continente de dois caracteres."
  type        = string
  default     = null
}

variable "geolocation-country" {
  description = "Codigo de pais com dois caracteres."
  type        = string
  default     = null
}

variable "geolocation-subdivision" {
  description = "Subdivisao para geolocalizacao."
  type        = string
  default     = null
}


# Latency
#--------
variable "latency-region" {
  description = "Regiao da AWS para medir a latencia."
  type        = string
  default     = null
}


# Failover
#---------
variable "failover-type" {
  description = "O registro PRIMARIO sera atendido se sua verificacao de integridade for aprovada, se nao o SECUNDARIO sera atendido."
  type        = string
  default     = null
}


# IP-based
#---------
variable "ip_based-collection_id" {
  description = "ID da colecao CIDR."
  type        = string
  default     = null
}

variable "ip_based-location_name" {
  description = "Nome do local de coleta CIDR."
  type        = string
  default     = null
}
