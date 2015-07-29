require 'csv'
class StartupFetcher
  ENDPOINT = "/api/company?fincestatus=0"

  def fetch
    response = ThirtySixKr.connection.get(ENDPOINT)
    json_response = JSON.parse(response.body)
    total_pages = json_response['data']['page']['totalPages']
    j
    CSV.open('startups.csv', 'wb') do |csv|
      csv << ["公司名称", "项目介绍", "投资人", "行业", "所在地", "融资阶段",]
    (1..total_pages).each do |page|
      response = ThirtySixKr.connection.get(ENDPOINT + "&page=#{page}&type=")
      startups = JSON.parse(response.body)['data']['page']['data']
      startups.each do |startup|
        company = startup['company']
        founder = startup['founder']

        startup_name = company['name']
        startup_desc = company['brief']
        founders = founder.map {|f| f['name']}.join(" ")
        startup_industry = company['industry']
        startup_address = company['address1']
        startup_finance_phase = company['financePhase'] 
        csv << [
          startup_name, startup_desc, fetch_founders(founder),
          startup_industry, startup_address, startup_finance_phase
        ]

      end
    end
    end
  end

  def fetch_founders(founders)
    founders.map do|founder|
      founder_id = founder['id']
      founder_name = founder['name']
      founder_response = ThirtySixKr.connection.get("/api/user/#{founder_id}/basic") 
      founder_info = JSON.parse(founder_response.body)['data']
      founder_avatar = founder_info['avatar']
      founder_linkedin = founder_info['linkedin'] || ""
      founder_weibo = founder_info['weibo'] || ""
      founder_weixin = founder_info['weixin'] || ""
      "[#{founder_name}, #{founder_avatar}, #{founder_linkedin}, #{founder_weibo},#{founder_weixin}]"
  end.join(":")
  end

end
