output "db_host" {
    value = "DB_HOST: ${module.rds.db_host}"
}
output "db_password" {
    value = "DB_PASSWORD: ${module.rds.db_password}"
}
output "ENV_URL" {
    value = "ENV_URL: ${module.beanstalk.env_url}"
}

