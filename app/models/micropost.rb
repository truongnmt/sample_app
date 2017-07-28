class Micropost < ApplicationRecord
  belongs_to :user

  mount_uploader :picture, PictureUploader

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.micropost_length.to_i}
  validate  :picture_size

  scope :order_desc, ->{order created_at: :DESC}
  feeds = lambda do |id|
    where "user_id IN (SELECT followed_id FROM relationships
      WHERE follower_id = #{id}) OR user_id = #{id}"
  end
  scope :feeds, feeds

  private

  def picture_size
    return unless picture.size > 5.megabytes

    errors.add :picture, I18n.t("should_be_less_than_5mb")
  end
end
