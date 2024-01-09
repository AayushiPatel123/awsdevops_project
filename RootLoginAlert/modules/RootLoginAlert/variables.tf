variable "event_name" {
  description = "The name of the Event"
  type = string
  default = ""
}

variable "sns_subscription" {
  type        = list(string)
  description = "Endpoint to send data to. The contents vary with the protocol."
  default     = [""]
}

variable "retention_in_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group."
  default     = 30
}