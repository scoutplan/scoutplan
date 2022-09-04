# frozen_string_literal: true

Dir[Rails.root.join("lib", "core_ext", "string", "*.rb")].each { |f| require f }
String.include CoreExtensions::String::TestMethods

# monkey-patched String class
class String
  describe "numeric?" do
    it "returns true when string is numeric" do
      expect("123".numeric?).to be_truthy
    end

    it "returns false when string is not numeric" do
      expect("Troop".numeric?).to be_falsey
    end
  end
end
