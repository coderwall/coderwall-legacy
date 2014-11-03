Fabricator(:team) do
  name { Faker::Company.name }
  account { Fabricate.build(:account) }
end
