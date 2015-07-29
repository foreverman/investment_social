require 'csv'
class InvestorFetcher
  ENDPOINT = "/api/organization/investor"

  def fetch
    response = ThirtySixKr.connection.get(ENDPOINT)
    json_response = JSON.parse(response.body)
    total_pages = json_response['data']['totalPages']
    CSV.open('investors.csv', 'wb') do |csv|
      csv << ["投资人姓名", "投资机构名称", "投资人头像", "linkedin", "微博", "微信", "投资领域", "投资的公司", "投资阶段", "投资总数/单笔可投"]
    (1..total_pages).each do |page|
      response = ThirtySixKr.connection.get(ENDPOINT + "?page=#{page}")
      investors = JSON.parse(response.body)['data']['data']
      investors.each do |investor|
        invest_com_count = investor['investComCount']
        user = investor['user']
        invest_com = investor['investCom'] || []
        name = user['name'] || ""
        intro = user['intro'] || ""
        avatar = user['avatar'] || "" 
        linkedin = user['linkedin'] || ""
        weibo = user['weibo'] || ""
        weixin = user['weixin'] || ""
        focus_industry_desc = build_focus_industry_desc(user)
        invest_coms = build_invest_coms(invest_com)
        invest_phase_desc = build_invest_phase_desc(user)
        csv << [
          name, intro, avatar, linkedin, weibo, weixin, 
          focus_industry_desc, invest_coms, invest_phase_desc, 
          build_invest_com_count_desc(user, invest_com_count)
        ]
      end
    end

    end
  end

  def build_focus_industry_desc(user)
    focus_industry = 
      user['focusIntustry'] && user['focusIntustry'].keys
    focus_industry ||= []
    focus_industry.join(" ")
  end
  def build_invest_phase_desc(user)
    invest_phase_descs = []
    invest_phase_descs << "早期" if user['isInvestFirstPhase']
    invest_phase_descs << "成长期" if user['isInvestSecondPhase']
    invest_phase_descs << "成熟期" if user['isInvestThirdPhase']
    invest_phase_descs.join(" ")
  end

  def build_invest_coms(invest_com)
    invest_coms = ""
    invest_coms = invest_com.map {|com| com['name']}.join(";")
  end

  def build_invest_com_count_desc(user, invest_com_count)
    result = ""
    result << "#{invest_com_count}个" if invest_com_count > 0
    if user['investMoneyBegin'] != "" && user['investMoneyEnd'] != ""
      result << "  "
      result << "¥#{user['investMoneyBegin']} - #{user['investMoneyEnd']} 万(#{build_enterpriser_desc(user)})"
    end
    result
  end

  def build_enterpriser_desc(user)
    case user['enterpriser']
    when 0 then '个人'
    when 1 then '机构'
    end
  end
end
