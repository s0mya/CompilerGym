# adds an http listener to the load balancer and allows ingress
# (delete this file if you only want https)

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.api.id
  port              = var.api_lb_port
  protocol          = var.api_lb_protocol
  certificate_arn   = var.api_cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
  # TODO sometimes terraform gets stuck deleting dependent reseources.
  # Inviestigate the following workaround as per https://github.com/hashicorp/terraform/issues/16065#issuecomment-328648133

  # lifecycle {
  #   replace_on_change = {
  #     target_group_id = "${aws_alb_target_group.service.id}"
  #   }
  # }
}

resource "aws_security_group_rule" "ingress_lb_https" {
  type              = "ingress"
  description       = var.api_lb_protocol
  from_port         = var.api_lb_port
  to_port           = var.api_lb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id

}
