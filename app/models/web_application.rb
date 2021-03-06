class WebApplication < ActiveRecord::Base
  include Requester
  extend FriendlyId
  has_paper_trail only: [:current_status]

  validates_presence_of :name, :status_url, :users
  validates_uniqueness_of :name
  validate :status_url_is_valid?, if: "status_url.present?"
  has_many :users, through: :user_web_applications, autosave: true
  has_many :user_web_applications
  friendly_id :name, use: :slugged
  attr_accessor :status_checked_at, :resources, :dependencies

  self.per_page = 10

  def get_current_status
    begin
      response = get(status_url)
    rescue
      self.current_status = "application unreachable"
      @status_checked_at = Time.now.utc
      return
    end
    self.current_status = response.try(:[], "status").try(:downcase)

    @status_checked_at = Time.at(response.try(:[], "updated").to_i).utc
    @resources = response.try(:[], "resources")
    @dependencies = response.try(:[], "dependencies")
  end

  def root_url
    uri = URI.parse(status_url)
    "#{uri.scheme}://#{uri.host}"
  end

private
  def status_url_is_valid?
    return if status_url == status_url_was
    begin
      get(status_url)
    rescue
      errors.add(:status_url, "is unavailable or does not return a valid response")
    end
  end
end
