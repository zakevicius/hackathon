require 'openai'
require './utility'

OpenAI.configure do |c|
  c.access_token = ENV['OPENAI_API_KEY']
end

client = OpenAI::Client.new

@information = Utility.collect_information

def system_instructions
  instr = ""
  instr << "You are helping technical support specialists at company 'Company JSC'\n" \
          " to find the reason why payout is failing. The information about current payout is given betweeen triple backtikcs ```\n" \
          "You are given a previous known 'Company JSC' issues related to failing payouts. The information is in JSON format. Each element of an array is a separate issue, which first key is a ticket number to which this incident is related. The value holds the following information:\n" \
          "1. Ticket data. Description of this particular ticket, when it was created and it's status. Also a resollution if issue was resolved. \n" \
          "2. Payment data. Amount, currency, status, payment service provider, date when it was initiated and possible reason from provider.\n" \
          "3. Customer data. Name, address and bank information. \n" \
          "All this history is provided between single backticks `  \n" \
          "Also you have a list of known incidents on payment service providers side. \n" \
          "Information is given as JSON with fields of provider name, incident description, and dates when incident started and ended. If there is no end date it means the incident is still ongoing. These incidents may be related to our failing payouts, but may be totally irrelevant. \n" \
          "This information is provided in between double backticks `` \n" \
          "Analyze the chat history and keep in mind possible reasons for this case. \n" \
          "Given the chat history, issues history and incidents history your task is to give a reason why payout may be failing. \n" \
          "If similar incidents are already happening provide with a list of ticket ids. \n" \
          "If you do not have enough information to figure out a reason just answer that this case is not known to you and offer to contact provider. \n"
  instr << "```#{@information[:current_incident_data]}```"
  instr << "`#{@information[:data]}`"
  instr << "``#{@information[:incidents]}``"
  instr << "The answer should be tehcnical and no longer than 150 words. Give details about current case. \n"
  instr << "In addition to answer before add if user mentioned why it may be happening nad possible reason"
end

@information[:messages] << {
  role: "system",
  content: system_instructions
}

while true
  response = client.chat(
    parameters: {
      model: "gpt-3.5-turbo", # Required.
      messages: @information[:messages], # Required.
      temperature: 1.5,
    }
  )

  ai_message = response.dig("choices", 0, "message", "content")

  @information[:messages] << {
    role: "assistant",
    content: ai_message,
  }

  puts ai_message

  new_prompt = gets.chomp

  if new_prompt == "exit"
    Utility.save_information(@information)
    break
  end

  @information[:messages] << {
    role: "user",
    content: new_prompt,
  }
end
