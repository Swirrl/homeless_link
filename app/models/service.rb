class Service

  include Mongoid::Document

  belongs_to :local_auth

  field :service_type
  field :name
  field :address
  field :tel
  field :website
  field :email
  field :service_offered

  def self.import_csv(csv_file_path)

    i = 0
    CSV.foreach(csv_file_path) do |row|

      puts i

      local_auth_code = row[9]

      local_auth = LocalAuth.where(:code => local_auth_code).first

      if local_auth
        local_auth.services.create!(
          name: row[0],
          address: row[18],
          service_offered: row[10],
          tel: row[7],
          website: row[11],
          email: row[8],
          service_type: (row[19] == "AF" ? "advice" : "hostel")
          )
      end
      i+=1
    end
  end




end