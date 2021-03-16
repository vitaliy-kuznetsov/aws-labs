output db_password {
    value = random_password.db_password.result
}
output db_host {
    value = aws_db_instance.lab-db.address
}