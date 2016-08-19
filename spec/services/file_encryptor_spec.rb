require 'rails_helper'

describe DiscourseBackupUploadsToS3::FileEncryptor do
  let(:secret_key) { 'U6ocWTLaXcvIvX5nSCYch5jV02Z+H9YQXaaIo8aNV/E=\n' }

  subject { described_class.new(secret_key) }

  def encrypt_and_decrypt_file(file)
    begin
      source = file.path
      destination = "#{source}.enc"

      subject.encrypt(source, destination)

      decrypted_destination = "#{File.dirname(source)}/output"
      subject.decrypt(destination, decrypted_destination)

      expect(File.read(decrypted_destination)).to eq(file.read)
    ensure
      File.delete(decrypted_destination) if File.exists?(decrypted_destination)
    end
  end

  it "should be able to encrypt and decrypt images correctly" do
    small_file = file_from_fixtures("logo.png")
    expect(small_file.size < described_class::BUFFER_SIZE).to eq(true)
    encrypt_and_decrypt_file(small_file)

    large_file = file_from_fixtures("large & unoptimized.png")
    expect(large_file.size > described_class::BUFFER_SIZE).to eq(true)
    encrypt_and_decrypt_file(large_file)
  end

  it "should be able to encrypt and decrypt a csv file correctly" do
    encrypt_and_decrypt_file(file_from_fixtures("discourse.csv", "csv"))
  end

  it "should be able to encrypt and decrypt a scss file correctly" do
    encrypt_and_decrypt_file(file_from_fixtures("my_plugin.scss", "scss"))
  end

  it "should be able to encrypt and decrypt a YAML file correctly" do
    encrypt_and_decrypt_file(file_from_fixtures("client.yml", "site_settings"))
  end

  describe "#encrypt" do
    it "yields a file that can be read" do
      image = file_from_fixtures("logo.png")
      subject.encrypt(image.path) { |enc_file| enc_file.read(1) }
    end
  end
end