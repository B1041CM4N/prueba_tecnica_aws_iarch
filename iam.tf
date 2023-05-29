# Creamos el grupo de usuarios por defecto para asociar al usuario
resource "aws_iam_group" "default_group" {
  name = "default-group"
  path = "/default-group/"
}

# Crear usuario IAM por defecto para asociar al grupo
resource "aws_iam_user" "prog_usr" {
  name = "prog-usr"
  path = "/default-group/prog-usr/"
}

# Agregar usuario al grupo definido anteriormente
resource "aws_iam_group_membership" "default_membership" {
  name    = "default-membership"
  group   = aws_iam_group.default_group.name
  users   = [aws_iam_user.prog_usr.name]
}

# Politica IAM por defecto para asociar al grupo de usuarios
resource "aws_iam_policy" "default_policy" {
  name        = "default-policy"
  path        = "/default-group/default-policy/"
  description = "Politica IAM por defecto"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
EOF
}

# Atachar la politica a el grupo de usuarios creado anteriormente
resource "aws_iam_group_policy_attachment" "default_policy_attachment" {
  group      = aws_iam_group.default_group.name
  policy_arn = aws_iam_policy.default_policy.arn
}