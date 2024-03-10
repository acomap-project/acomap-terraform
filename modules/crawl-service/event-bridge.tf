resource "aws_scheduler_schedule_group" "acomap" {
  name = "acomap"
}

resource "aws_scheduler_schedule" "crawl-scheduler" {
  name        = "CRAWL_crawl-scheduler"
  description = "Crawl scheduler for Crawl Service"
  // create schedule expression to run every 2 minutes
  schedule_expression          = "cron(0 0 * * ? *)"
  schedule_expression_timezone = "Asia/Ho_Chi_Minh"
  group_name                   = aws_scheduler_schedule_group.acomap.name
  depends_on = [ aws_iam_role.crawl-scheduler-role ]

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_sfn_state_machine.crawl-workflow.arn
    role_arn = aws_iam_role.crawl-scheduler-role.arn
    input = jsonencode({
      "area_list" : [
        {
          "city" : "Hồ Chí Minh",
          "district" : "Quận Bình Thạnh",
          "city_code" : "ho-chi-minh",
          "district_code" : "quan-binh-thanh"
        },
        {
          "city" : "Hồ Chí Minh",
          "district" : "Quận Thủ Đức",
          "city_code" : "ho-chi-minh",
          "district_code" : "quan-thu-duc"
        },
        {
          "city" : "Hồ Chí Minh",
          "district" : "Quận Phú Nhuận",
          "city_code" : "ho-chi-minh",
          "district_code" : "quan-phu-nhuan"
        },
        {
          "city" : "Hồ Chí Minh",
          "district" : "Quận 1",
          "city_code" : "ho-chi-minh",
          "district_code" : "quan-1"
        },
        {
          "city" : "Hồ Chí Minh",
          "district" : "Quận 4",
          "city_code" : "ho-chi-minh",
          "district_code" : "quan-4"
        },
        {
          "city" : "Hồ Chí Minh",
          "district" : "Quận 10",
          "city_code" : "ho-chi-minh",
          "district_code" : "quan-10"
        }
      ]
    })
  }
}
