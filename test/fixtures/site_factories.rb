Factory.sequence(:domain) {|n| "example-#{n}.com"}

Factory.define :site do |site|
  site.name         'WordPress Blog'
  site.domains      { Factory.next :domain }
end