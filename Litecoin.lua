-- Inofficial Litecoin Extension for MoneyMoney
-- Fetches Litecoin quantity for addresses via chain.so API
-- Fetches Litecoin price in EUR via cryptocompare.com API
-- Returns cryptoassets as securities
--
-- Username: Litecoin Adresses comma seperated
-- Password: [Whatever]

-- MIT License

-- Copyright (c) 2017 Zafai

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 0.1,
  description = "Include your Litecoins as cryptoportfolio in MoneyMoney by providing Litecoin addresses as usernme (comma seperated) and a random Password",
  services= { "Litecoin" }
}

local litecoinAddress
local connection = Connection()
local currency = "EUR"

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Litecoin"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  litecoinAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Litecoin",
    accountNumber = "Litecoin",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestLitecoinPrice()

  for address in string.gmatch(litecoinAddress, '([^,]+)') do
    litecoinQuantity = requestLitecoinQuantityForLitecoinAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = litecoinQuantity,
      price = prices,
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestLitecoinPrice()
  response = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(response)

  return json:dictionary()['EUR']
end

function requestLitecoinQuantityForLitecoinAddress(litecoinAddress)
  response = connection:request("GET", litecoinRequestUrl(litecoinAddress), {})
  json = JSON(response)
  
  return json:dictionary()['data']['confirmed_balance']
end


-- Helper Functions

function cryptocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=LTC&tsyms=EUR"
end 

function litecoinRequestUrl(litecoinAddress)
  return "https://chain.so/api/v2/get_address_balance/LTC/" .. litecoinAddress .. ""
end

