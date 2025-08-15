resource "aws_route53_record" "atlantis" {
  zone_id = var.zone_id    # ID de tu zona DNS
  name    = "atlantiserickfrontend.com"
  type    = "A"
  ttl     = 300
  records = ["18.118.157.213"]  # tu IP pública
}
