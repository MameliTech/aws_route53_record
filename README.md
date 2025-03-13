# AWS Route 53 DNS Record

![Provedor](https://img.shields.io/badge/provider-AWS-orange) ![Engine](https://img.shields.io/badge/engine-Route_53_DNS_Record-blueviolet) ![Versão](https://img.shields.io/badge/version-1.0.0-success) ![Coordenação](https://img.shields.io/badge/coord.-Mameli_Tech-informational)<br>

Módulo desenvolvido para o provisionamento de **AWS Route 53 DNS Record**.

Este módulo tem como objetivo criar um Route 53 DNS Record seguindo os padrões da Mameli Tech.

Serão criados os seguintes recursos:
1. **Route 53-Record** com o nome no padrão <span style="font-size: 12px;">`Subdomínio.Domínio`</span>

## Como utilizar?

### Passo 1

Precisamos configurar o Terraform para armazenar o estado dos recursos criados.<br>
Caso não exista um arquivo para este fim, crie o arquivo `tf_01_backend.tf` com o conteúdo abaixo:

```hcl

#==================================================================
# backend.tf - Script de definicao do Backend
#==================================================================

terraform {
  backend "s3" {
    encrypt = true
  }
}
```

### Passo 2

Precisamos armazenar as definições de variáveis que serão utilizadas pelo Terraform.<br>
Caso não exista um arquivo para este fim, crie o arquivo `tf_02_variables.tf` com o conteúdo a seguir.<br>
Caso exista, adicione o conteúdo abaixo no arquivo:

```hcl
#==================================================================
# variables.tf - Script de definicao de Variaveis
#==================================================================

#------------------------------------------------------------------
# Provider
#------------------------------------------------------------------
variable "account_region" {
  description = "Regiao onde os recursos serao alocados."
  type        = string
  default     = "us-east-1"
  nullable    = false
}

variable "profile" {
  description = "Perfil AWS."
  type        = string
  default     = "devops"
  nullable    = false
}


#------------------------------------------------------------------
# Resource Nomenclature & Tags
#------------------------------------------------------------------
variable "default_tags" {
  description = "TAGs padrao que serao adicionadas a todos os recursos."
  type        = map(string)
}


#------------------------------------------------------------------
# Route 53 DNS Record
#------------------------------------------------------------------
variable "route53-record" {
  type = map(object({
    domain_name                  = string
    name                         = string
    type                         = string
    ttl                          = number
    records                      = optional(list(string))
    set_identifier               = optional(string)
    policy                       = string
    health_check_id              = optional(string)
    alias-name                   = optional(string)
    alias-zone_id                = optional(string)
    alias-evaluate_target_health = optional(bool)
    weighted-weight              = optional(number)
    geolocation-country          = optional(string)
    geolocation-continent        = optional(string)
    geolocation-subdivision      = optional(string)
    failover-type                = optional(string)
    latency-region               = optional(string)
    ip_based-collection_id       = optional(string)
    ip_based-location_name       = optional(string)
  }))
}
```

### Passo 3

Precisamos configurar informar o Terraform em qual região os recursos serão implementados.<br>
Caso não exista um arquivo para este fim, crie o arquivo `tf_03_provider.tf` com o conteúdo abaixo:

```hcl
#==================================================================
# provider.tf - Script de definicao do Provider
#==================================================================

provider "aws" {
  region  = var.account_region
  profile = var.profile

  default_tags {
    tags = var.default_tags
  }
}
```

### Passo 4

O script abaixo será responsável pela chamada do módulo.<br>
Crie um arquivo no padrão `tf_NN_route53-record.tf` com o conteúdo abaixo:

```hcl
#====================================================================
# route53-record.tf - Script de chamada do modulo Route 53 DNS Record
#====================================================================

module "route53-record" {
  source   = "git@github.com:MameliTech/aws_route53_record.git"
  for_each = var.route53-record

  domain_name                  = each.value.domain_name
  name                         = each.value.name
  type                         = each.value.type
  ttl                          = each.value.ttl
  records                      = each.value.records
  set_identifier               = each.value.set_identifier
  policy                       = each.value.policy
  health_check_id              = each.value.health_check_id
  alias-name                   = each.value.alias-name
  alias-zone_id                = each.value.alias-zone_id
  alias-evaluate_target_health = each.value.alias-evaluate_target_health
  weighted-weight              = each.value.weighted-weight
  geolocation-continent        = each.value.geolocation-continent
  geolocation-country          = each.value.geolocation-country
  geolocation-subdivision      = each.value.geolocation-subdivision
  latency-region               = each.value.latency-region
  failover-type                = each.value.failover-type
  ip_based-collection_id       = each.value.ip_based-collection_id
  ip_based-location_name       = each.value.ip_based-location_name
}
```

### Passo 5

O script abaixo será responsável por gerar os Outputs dos recursos criados.<br>
Crie um arquivo no padrão `tf_99_outputs.tf` e adicione:

```hcl
#==================================================================
# outputs.tf - Script para geracao de Outputs
#==================================================================

output "all_outputs" {
  description = "Todos os outputs do modulo Route 53 Record Set."
  value       = module.route53-record
}
```

### Passo 6

Adicione uma pasta env com os arquivos `dev.tfvars`, `hml.tfvars` e `prd.tfvars`. Em cada um destes arquivos você irá informar os valores das variáveis que o módulo utiliza.

Segue um exemplo do conteúdo de um arquivo `tfvars`:

```hcl
#==================================================================
# dev.tfvars - Arquivo de definicao de Valores de Variaveis
#==================================================================

#------------------------------------------------------------------
# Provider
#------------------------------------------------------------------
account_region = "us-east-1"
profile        = "devops"


#------------------------------------------------------------------
# Resource Nomenclature & Tags
#------------------------------------------------------------------
default_tags = {
  "N_projeto" : "DevOps Lab"                                                            # Nome do projeto
  "N_ccusto_ti" : "Mameli-TI-2025"                                                      # Centro de Custo TI
  "N_ccusto_neg" : "Mameli-Business-2025"                                               # Centro de Custo Negocio
  "N_info" : "Para maiores informacoes procure a Mameli Tech - consultor@mameli.com.br" # Informacoes adicionais
  "T_funcao" : "Record Set do Route 53"                                                 # Funcao do recurso
  "T_versao" : "1.0"                                                                    # Versao de provisionamento do ambiente
  "T_backup" : "nao"                                                                    # Descritivo se sera realizado backup automaticamente dos recursos provisionados
}


#------------------------------------------------------------------
# Route 53 DNS Record
#------------------------------------------------------------------
route53-record = {
  # Exemplo que cria um DNS Record do tipo simple (permite apenas uma regra com mesmo name/subdominio)
  # com distribuicao de trafego balanceada (Round-Robin) nos IPs da lista (records)
  simple1 = {
    domain_name                  = "imeng.top"
    name                         = "sim1"
    type                         = "A"
    ttl                          = 60
    records                      = ["54.236.240.141"]
    set_identifier               = null
    health_check_id              = null
    policy                       = "simple"
    alias-name                   = null
    alias-zone_id                = null
    alias-evaluate_target_health = null
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo simple (permite apenas uma regra com mesmo name/subdominio)
  # com direcionamento do trafego para um recurso existente no ambiente com base em seu alias
  simple2 = {
    domain_name                  = "imeng.top"
    name                         = "sim2"
    type                         = "A"
    ttl                          = null
    records                      = null
    set_identifier               = null
    health_check_id              = null
    policy                       = "simple"
    alias-name                   = "test.imeng.top"
    alias-zone_id                = "Z05890886GMG49AMNI6F"
    alias-evaluate_target_health = false
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo weighted (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseada pelo peso do record (weighted-weight)
  # O primeiro direciona o trafego de forma balanceada (Round-Robin) nos IPs da lista (records)
  weighted1 = {
    domain_name                  = "imeng.top"
    name                         = "wei"
    type                         = "A"
    ttl                          = 60
    records                      = ["54.236.240.141"]
    set_identifier               = "weighted1"
    health_check_id              = null
    policy                       = "weighted"
    alias-name                   = null
    alias-zone_id                = null
    alias-evaluate_target_health = null
    weighted-weight              = 10
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo weighted (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseada pelo peso do record (weighted-weight)
  # O segundo direciona o trafego para um recurso existente no ambiente com base em seu alias
  weighted2 = {
    domain_name                  = "imeng.top"
    name                         = "wei"
    type                         = "A"
    ttl                          = null
    records                      = null
    set_identifier               = "weighted2"
    health_check_id              = null
    policy                       = "weighted"
    alias-name                   = "test.imeng.top"
    alias-zone_id                = "Z05890886GMG49AMNI6F"
    alias-evaluate_target_health = false
    weighted-weight              = 20
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo geolocation (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseada na localizacao da origem (geolocation-continent/country/subdivision)
  # O primeiro direciona o trafego de forma balanceada (Round-Robin) nos IPs da lista (records)
  geo1 = {
    domain_name                  = "imeng.top"
    name                         = "geo"
    type                         = "A"
    ttl                          = 60
    records                      = ["54.236.240.141"]
    set_identifier               = "geolocation1"
    health_check_id              = null
    policy                       = "geolocation"
    alias-name                   = null
    alias-zone_id                = null
    alias-evaluate_target_health = null
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = "BR"
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo geolocation (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseada na localizacao da origem (geolocation-continent/country/subdivision)
  # O segundo direciona o trafego para um recurso existente no ambiente com base em seu alias
  geo2 = {
    domain_name                  = "imeng.top"
    name                         = "geo"
    type                         = "A"
    ttl                          = null
    records                      = null
    set_identifier               = "geolocation2"
    health_check_id              = null
    policy                       = "geolocation"
    alias-name                   = "test.imeng.top"
    alias-zone_id                = "Z05890886GMG49AMNI6F"
    alias-evaluate_target_health = false
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = "US"
    geolocation-subdivision      = "DC"
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo failover (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego para o PRIMARY e, em caso de falha, para o SECONDARY
  # Necessita de um Health Check
  # O primeiro direciona o trafego de forma balanceada (Round-Robin) nos IPs da lista (records)
  failover1 = {
    domain_name                  = "imeng.top"
    name                         = "fail"
    type                         = "A"
    ttl                          = 60
    records                      = ["54.236.240.141"]
    set_identifier               = "failover1"
    health_check_id              = "a654046a-5512-4f30-8442-2b90c85428c1"
    policy                       = "failover"
    alias-name                   = null
    alias-zone_id                = null
    alias-evaluate_target_health = null
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = "PRIMARY"
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo failover (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego para o PRIMARY e, em caso de falha, para o SECONDARY
  # Necessita de um Health Check
  # O segundo direciona o trafego para um recurso existente no ambiente com base em seu alias
  failover2 = {
    domain_name                  = "imeng.top"
    name                         = "fail"
    type                         = "A"
    ttl                          = null
    records                      = null
    set_identifier               = "failover2"
    health_check_id              = null
    policy                       = "failover"
    alias-name                   = "test.imeng.top"
    alias-zone_id                = "Z05890886GMG49AMNI6F"
    alias-evaluate_target_health = false
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = "SECONDARY"
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo latency (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseado na latencia entre a origem e a regiao (latency-region)
  # O primeiro direciona o trafego de forma balanceada (Round-Robin) nos IPs da lista (records)
  latency1 = {
    domain_name                  = "imeng.top"
    name                         = "lat"
    type                         = "A"
    ttl                          = 60
    records                      = ["54.236.240.141"]
    set_identifier               = "latency1"
    health_check_id              = null
    policy                       = "latency"
    alias-name                   = null
    alias-zone_id                = null
    alias-evaluate_target_health = null
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = "sa-east-1"
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo latency (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseado na latencia entre a origem e a regiao (latency-region)
  # O segundo direciona o trafego para um recurso existente no ambiente com base em seu alias
  latency2 = {
    domain_name                  = "imeng.top"
    name                         = "lat"
    type                         = "A"
    ttl                          = null
    records                      = null
    set_identifier               = "latency2"
    health_check_id              = null
    policy                       = "latency"
    alias-name                   = "test.imeng.top"
    alias-zone_id                = "Z05890886GMG49AMNI6F"
    alias-evaluate_target_health = false
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = "us-east-1"
    ip_based-collection_id       = null
    ip_based-location_name       = null
  },
  # Exemplo que cria um DNS Record do tipo ip-based (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseado na verificacao se o IP origem pertence a uma determinada colecao (ip_based-collection_id/location_name)
  # Necessita de um IP Based Collection
  # O primeiro direciona o trafego de forma balanceada (Round-Robin) nos IPs da lista (records)
  ipbased1 = {
    domain_name                  = "imeng.top"
    name                         = "ipb"
    type                         = "A"
    ttl                          = 60
    records                      = ["54.236.240.141"]
    set_identifier               = "ip-based1"
    health_check_id              = null
    policy                       = "ip-based"
    alias-name                   = null
    alias-zone_id                = null
    alias-evaluate_target_health = null
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = "5cc58aae-40e8-7201-dabc-fd22f06f768d"
    ip_based-location_name       = "ntt_saopaulo"
  },
  # Exemplo que cria um DNS Record do tipo ip-based (permite mais de uma regra com mesmo name/subdominio)
  # com distribuicao de trafego baseado na verificacao se o IP origem pertence a uma determinada colecao (ip_based-collection_id/location_name)
  # Necessita de um IP Based Collection
  # O segundo direciona o trafego para um recurso existente no ambiente com base em seu alias
  ipbased2 = {
    domain_name                  = "imeng.top"
    name                         = "ipb"
    type                         = "A"
    ttl                          = null
    records                      = null
    set_identifier               = "ip-based2"
    health_check_id              = null
    policy                       = "ip-based"
    alias-name                   = "test.imeng.top"
    alias-zone_id                = "Z05890886GMG49AMNI6F"
    alias-evaluate_target_health = false
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = "5cc58aae-40e8-7201-dabc-fd22f06f768d"
    ip_based-location_name       = "*"
  },
  # Exemplo que cria um DNS Record do tipo multivalue (permite apenas uma regra com mesmo name/subdominio)
  # Este segue o modelo do tipo simple (Round-Robin) mas permite a criacao de varias regras com o mesmo name/subdominio
  mult = {
    domain_name                  = "imeng.top"
    name                         = "mult"
    type                         = "A"
    ttl                          = 60
    records                      = ["54.236.240.141"]
    set_identifier               = "multivalue"
    health_check_id              = null
    policy                       = "multivalue"
    alias-name                   = null
    alias-zone_id                = null
    alias-evaluate_target_health = null
    weighted-weight              = null
    geolocation-continent        = null
    geolocation-country          = null
    geolocation-subdivision      = null
    failover-type                = null
    latency-region               = null
    ip_based-collection_id       = null
    ip_based-location_name       = null
  }
}
```

<br>

## Provedores

| Nome | Versão |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.84.0 |

## Recursos

| Nome | Tipo |
|------|------|
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Entradas do módulo

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Dominio existente no Route 53 Hosted Zone. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Subdominio do registro. | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Tipo de registro. | `string` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Time-to-Live (TTL) do registro. | `number` | n/a | yes |
| <a name="input_records"></a> [records](#input\_records) | Lista de destinos associados ao subdominio. | `list(string)` | `[]` | no |
| <a name="input_set_identifier"></a> [set\_identifier](#input\_set\_identifier) | ID que deseja associar ao registro. | `string` | `null` | no |
| <a name="input_health_check_id"></a> [health\_check\_id](#input\_health\_check\_id) | ID do Health Check do Route 53 associada ao registro. | `string` | `null` | no |
| <a name="input_alias-name"></a> [alias-name](#input\_alias-name) | Nome do recurso destino. | `string` | `null` | no |
| <a name="input_alias-zone_id"></a> [alias-zone\_id](#input\_alias-zone\_id) | Zone ID do recurso destino. | `string` | `null` | no |
| <a name="input_alias-evaluate_target_health"></a> [alias-evaluate\_target\_health](#input\_alias-evaluate\_target\_health) | Determina se o Route 53 deve avaliar a saude dos destinos associados ao alias. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Identifica qual politica deve ser adotada para o registro. Valores possiveis: simple, weighted, geolocation, failover, latency, ip-based ou multivalue. | `string` | `null` | no |
| <a name="input_weighted-weight"></a> [weighted-weight](#input\_weighted-weight) | Valor numerico que indica o peso relativo do registro. | `number` | `null` | no |
| <a name="input_geolocation-continent"></a> [geolocation-continent](#input\_geolocation-continent) | Codigo de continente de dois caracteres. | `string` | `null` | no |
| <a name="input_geolocation-country"></a> [geolocation-country](#input\_geolocation-country) | Codigo de pais de dois caracteres. | `string` | `null` | no |
| <a name="input_geolocation-subdivision"></a> [geolocation-subdivision](#input\_geolocation-subdivision) | Subdivisao para geolocalizacao. | `string` | `null` | no |
| <a name="input_latency-region"></a> [latency-region](#input\_latency-region) | Regiao da AWS para medir a latencia. | `string` | `null` | no |
| <a name="input_failover-type"></a> [failover-type](#input\_failover-type) | O registro PRIMARIO sera atendido se sua verificacao de integridade for aprovada, se nao o SECUNDARIO sera atendido. | `string` | `null` | no |
| <a name="input_ip_based-collection_id"></a> [ip\_based-collection\_id](#input\_ip\_based-collection\_id) | ID da colecao CIDR. | `string` | `null` | no |
| <a name="input_ip_based-location_name"></a> [ip\_based-location\_name](#input\_ip\_based-location\_name) | Nome do local de coleta CIDR. | `string` | `null` | no |

## Saída dos módulos

| Nome | Descrição |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | O ID da conta AWS. |
| <a name="output_account_region"></a> [account\_region](#output\_account\_region) | A regiao que hospeda os recursos. |
| <a name="output_record_id"></a> [record\_id](#output\_record\_id) | O ID do Route 53 Record Set. |
| <a name="output_name"></a> [name](#output\_name) | O nome do Route 53 Record Set. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | O FQDN: URL completa formada pelo Record Set e o Hosted Zone. |

<br><br><hr>

<div align="right">

<strong> Data da última versão: &emsp; 09/03/2025 </strong>

</div>
