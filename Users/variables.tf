variable "iam_usernames" {
    type = list(any)
    default = ["developers", "manager"]
}

variable "env" {
    type = list(any)
    default = ["Development", "Production"]
}

variable "env" {
    type = map(string)
    default = {
        Env = "Production"
    }
}