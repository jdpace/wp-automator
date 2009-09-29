module ShouldHaveStatesMacros
  
  def should_have_states(*states)
    klass = self.name.gsub(/Test$/, '').constantize
    
    context "defining AASM states" do
      setup do
        @model = klass.new
      end
      
      states.each do |state|
        should "have tell if it is in the #{state.to_s} state" do
          assert @model.respond_to?("#{state.to_s}?")
        end
        
        should "have a named scope to find all the #{state} #{klass.name.underscore}" do
          assert klass.respond_to?(state)
        end
      end
    end
  end
  
end

class Test::Unit::TestCase
  extend ShouldHaveStatesMacros
end