Factory.define :user do |user|
  user.name                   "example"
  user.email                  "123@123.com"
  user.password               "foobar"
  user.password_confirmation  "foobar"
end
Factory.sequence :email do |n|
  "person-#{n}@example.com"
end
