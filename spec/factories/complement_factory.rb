FactoryGirl.define do

  factory :complement, traits: [:guide_container] do
    book { Organization.current.book rescue nil }
    guide
  end
end
