resource "aws_alb_target_group" "nomad" {
  count = "${var.nomad_type == "server" ? 1 : 0}"

  name     = "${var.namespace}-nomad"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/v1/agent/self"
  }
}

resource "aws_alb_target_group" "consul" {
  count = "${var.consul_type == "client" ? 1 : 0}"

  name     = "${var.namespace}-consul"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/v1/status/leader"
  }
}

resource "aws_alb_target_group" "http_test" {
  count = "${var.nomad_type == "client" ? 1 : 0}"

  name     = "${var.namespace}-http-test"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/"
    port = 8080
  }
}

resource "aws_alb_target_group" "ui" {
  count = "${var.hashiui_enabled == 1 ? 1 : 0}"

  name     = "${var.namespace}-ui"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/nomad"
  }
}

resource "aws_alb_target_group" "github" {
  count = "${var.nomad_type == "client" ? 1 : 0}"

  name     = "${var.namespace}-github"
  port     = 5001
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/status/health"
    port = 5001
  }
}

resource "aws_alb_listener" "nomad" {
  count = "${var.nomad_type == "server" ? 1 : 0}"

  load_balancer_arn = "${var.internal_alb_arn}"
  port              = "4646"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nomad.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "consul" {
  count = "${var.consul_type == "client" ? 1 : 0}"

  load_balancer_arn = "${var.internal_alb_arn}"
  port              = "8500"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.consul.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "http" {
  count = "${var.nomad_type == "client" ? 1 : 0}"

  load_balancer_arn = "${var.external_alb_arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.http_test.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "github-connector" {
  count = "${var.nomad_type == "client" ? 1 : 0}"

  load_balancer_arn = "${var.internal_alb_arn}"
  port              = "5001"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.github.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "ui" {
  count = "${var.hashiui_enabled == 1 ? 1 : 0}"

  load_balancer_arn = "${var.external_alb_arn}"
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ui.arn}"
    type             = "forward"
  }
}
