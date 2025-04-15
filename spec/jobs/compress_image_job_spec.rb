require 'rails_helper'

RSpec.describe CompressImageJob, type: :job do
  let(:post) { create :post } 

  it 'processes and re-attaches compressed image' do
    expect(post.image).to be_attached

    described_class.perform_now(post.id)

    post.reload

    expect(post.image).to be_attached
    expect(post.image.content_type).to eq('image/jpeg')
  end

  it 'retries 3 times if MiniMagick raises an error' do
    allow(Post).to receive(:find).and_return(post)
    allow(post.image).to receive(:download).and_raise(MiniMagick::Error)

    expect(post.image).to receive(:download).exactly(3).times

    expect {
      described_class.perform_now(post.id)
    }.to raise_error(MiniMagick::Error)
  end
end
