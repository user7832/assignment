variable "we_apikey" {
    type = string
    description = "API key for weatherapi.com service"
}

variable "we_city" {
    type = string
    description = "City which temprerature will be checked"
    default = "Tallin"
}

variable "key_name" {
    type = string
    description = "AWS Key-pair name"
}
