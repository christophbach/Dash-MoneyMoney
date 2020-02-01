-- Inofficial Dash Extension for MoneyMoney
-- Fetches Dash quantity for addresses via blockcypher.com API
-- Fetches Dash price in EUR via cryptocompare.com API
-- Returns crypto assets as securities
--
-- Username: Dash adresses, comma seperated
-- Password: not needed

-- MIT License

-- Copyright (c) 2020 Christoph Bach

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
  description = "Include your Dash as crypto portfolio in MoneyMoney by providing Dash addresses as username (comma seperated).",
  services = { "Dash" }
}

local dashAddress
local connection = Connection()
local currency = "EUR"

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Dash"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  dashAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Dash",
    accountNumber = "Dash",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return { account }
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestDashPrice()

  for address in string.gmatch(dashAddress, '([^,]+)') do
    dashQuantity = requestDashQuantityForDashAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = dashQuantity,
      price = prices,
    }
  end

  return { securities = s }
end

function EndSession ()
end


-- Querry Functions
function requestDashPrice()
  response = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(response)

  return json:dictionary()['EUR']
end

function requestDashQuantityForDashAddress(dashAddress)
  response = connection:request("GET", dashRequestUrl(dashAddress), {})
  json = JSON(response)
  balance = json:dictionary()['balance']

  return convertSatoshiToDash(balance)
end


-- Helper Functions
function convertSatoshiToDash(satoshi)
  return satoshi / 100000000
end

function cryptocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=DASH&tsyms=EUR"
end

function dashRequestUrl(dashAddress)
  return "https://api.blockcypher.com/v1/dash/main/addrs/" .. dashAddress .. "/balance"
end