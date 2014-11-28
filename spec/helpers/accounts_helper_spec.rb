require 'spec_helper'

RSpec.describe AccountsHelper, type: :helper, skip: true do
  it '#invoice_date formats inovoice date from unix time' do
    invoice = { date: 1_068_854_400 }
    expect(helper.invoice_date(invoice)).to eq('November 15th, 2003')
  end

  it '#card_for returns card for a customer' do
    customer = { cards: ['test'] }
    expect(helper.card_for(customer)).to eq('test')
  end

  it '#subscription_period returns start and end dates for a subscription in the invoice' do
    invoice = {
      lines: {
        data: [{
          period: {
            start: 1_005_523_200,
            end: 1_351_728_000
          }
        }]
      }
    }
    expect(helper.subscription_period_for(invoice, :start)).to eq('November 12th, 2001')
    expect(helper.subscription_period_for(invoice, :end)).to eq('November 1st, 2012')
  end
end
