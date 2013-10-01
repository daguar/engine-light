desc "Checks application statuses via heroku scheduler"
task :check_app_statuses => :environment do
  WebApplication.all.each do |web_app|
    puts ENV['SENDGRID_USERNAME']
    puts ENV['SENDGRID_PASSWORD']
    # if web_app.get_status != "ok"
      WebApplicationMailer.outage_notification(web_app).deliver
    # end
  end
end