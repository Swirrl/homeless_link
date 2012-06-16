class LocalAuth

  include Mongoid::Document

  has_many :services

  field :snac, type: String
  field :code, type: String

  def self.import_csv(csv_file_path)
    CSV.foreach(csv_file_path) do |row|
      LocalAuth.create!(
        :snac => row[0],
        :code => row[2]
      )
    end
  end


end