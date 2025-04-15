class CompressImageJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)

    retries ||= 3

    begin
      io = post.image.download

      image = MiniMagick::Image.read(io)
      image.format("jpeg")
      image.resize "800x800"
      image.quality 85

      processed_io = StringIO.new(image.to_blob)

      post.image.attach(io: processed_io, filename: post.image.filename.to_s, content_type: post.image.content_type)
    rescue MiniMagick::Error => e
      if (retries -= 1) > 0
        sleep 1
        retry
      else 
        Rails.logger.info("All retries failed")
        raise
      end
    end
  end
end
